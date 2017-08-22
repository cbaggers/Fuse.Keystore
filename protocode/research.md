# Android - warning androids use of CA is confusing

https://developer.android.com/training/articles/security-ssl.html#ClientCert

you can teach HttpsURLConnection to trust a specific set of CAs.
- take a specific CA from an InputStream
- use it to create a KeyStore
- use that to create and initialize a TrustManager.

A TrustManager is what the system uses to validate certificates from
the server and—by creating one from a KeyStore with one or more
CAs—those will be the only CAs trusted by that TrustManager.

Given a TrustManager you can initialize a new SSLContext which
provides an SSLSocketFactory you can use to override the default
SSLSocketFactory from HttpsURLConnection.

To use a self signed cert you create your own TrustManager, trusting
the server certificate directly.

## KeyStore

A storage facility for cryptographic keys and certificates.

stores entries of 3 kinds:
- KeyStore.PrivateKeyEntry
- KeyStore.SecretKeyEntry
- KeyStore.TrustedCertificateEntry (trusted public key)

Each entry in a keystore is identified by an "alias" string.
Whether aliases are case sensitive is implementation dependent :|


## TrustManager

TrustManagers are responsible for managing the trust material that is
used when making trust decisions, and for deciding whether credentials
presented by a peer should be accepted.

The trust material for a TrustManagerFactory is based on a KeyStore
and/or provider specific sources

## Provider

https://docs.oracle.com/javase/8/docs/technotes/guides/security/crypto/CryptoSpec.html#Provider

implements some or all parts of Java Security. Services that
a provider may implement include:

- Algorithms (such as DSA, RSA, MD5 or SHA-1).
- Key generation, conversion, and management facilities (such as for
  algorithm-specific keys).

Each provider has a name and a version number, and is configured in
each runtime it is installed in.

# iOS
http://www.techrepublic.com/blog/software-engineer/use-https-certificate-handling-to-protect-your-ios-app/
https://developer.apple.com/documentation/security/certificate_key_and_trust_services

A certificate is a collection of data that identifies its owner in a
tamper-evident way.

An identity object is a certificate packaged together with its
corresponding private key.

a trust policy (or other criteria) are used to answer the 'Can I trust
this certificate' question.

After you have a key whose origin you trust, you can begin to conduct
cryptographic operations, such as encryption or data signing and
verification.

iOS strongly recommends using the SecurityInterface framework to
ensure a consistent experience when displaying certificates and trust
settings to the user and when the user chooses among identities or
modifies keychain settings.

## Certificate

A collection of data used to securely distribute the public half of a public/private key pair.

To evaluate a certificate, you first verify its signature using the
specified algorithm and the issuer's public key, which you obtain from
the issuer's publicly available certificate. This is recursive so you
evaluate the issuers cert back to a trusted root authority.

Cert can be obtained from an identity (in PKCS #12 file), DER-encoded data, or the keychain.

DER file is unencypted and PKCS is meant to be secure and can be loaded into the keychain

The opaque SecCertificateRef type seems to be what is used most places in the api (except for exchange format naturally)

## Certificate extensions

Additional information and conditions, like acceptable uses for the public key

## Keychain

Can store the following in the keychain:
- Certificate
- GenericPassword
- Identity
- InternetPassword
- Key

https://developer.apple.com/documentation/security/certificate_key_and_trust_services/certificates/storing_a_certificate_in_the_keychain

seems to be simple queries to add and get entries. Also allows labels
which may match up with android's aliases

https://developer.apple.com/documentation/security/certificate_key_and_trust_services/certificates/examining_a_certificate
reading a cert is what you would expect.

## Key

'A string of bytes that you combine with other data in specialized mathematical operations to enhance security'

can store in keystore (surprise!), calc public key from private, convert to nsdata, etc

https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_keychain
like certs the process for storing & retrieving keys is a query
against the store. In both of these it seems possible to have
duplicate names so we should search first and soft fail if dup found

## Identity

No surprises here given the above

## Policies

For a certificate that is deemed intact and valid (because the chain
of signatures is unbroken back to a trusted root certificate), you
evaluate it against a set of rules known as a trust policy. The policy
indicates how particular fields or extensions of a certificate affect
whether it should be trusted for a particular use.

Standard is X509 or SSL but you could create your own policy. We wont
be expose this yet

## Trust

By checking a cert for validity according to CA chain then *and*
validating using a policy you get a Trust object.

## Threading

iOS will shit itself if you try and use the apis from multiple threads
at the same time.

# Windows c++ (WinCrypt)

Has 'Cryptography Service Providers' (CSPs) which provide the crypto operations.

- Message is used to refer to any piece of data
- Plain text is used to refer to data that has not been encrypted.
- Cipher text refers to data that has been encrypted.
- hashing/hash" refers to the method used to derive a numeric value from a piece of data

## CSPs

At least one is provided with windows.

Each CSP has a key database.

Don't make decisions assuming how CSPs behave (size of keys etc).

CSP handles are reference counted

CSPs have a type called a 'Provider Type' these can be queried with
CryptEnumProviderTypes

CSPs can be queried for what operations they support (and other
details). These can be manipulated with CryptGetProvParam &
CryptSetProvParam.

## CSP key database

The database has containers.

The container has a unique name.

Generally, a default key container is created for each user.
This key container takes the user's logon name as its own name.
They contain all the key pairs belonging to that user.

Applications can also create its own key container (and key pairs),
which they usually name after themselves.

## Keys

can be persistent or session keys. Naturally, the former are persisted
in a CSP database container. The latter are not.

Apps can save session keys into application space in the form of an
encrypted key binary large object or key blob using the CryptExportKey
function.

- CryptDeriveKey generates a key from a specified password.
- CryptGenKey generates a key from random generated data.
- CryptDestroyKey releases the handle to the key object.

CryptGenKey is commonly used with the CRYPT_EXPORTABLE parameter as
this lets be used on other machines/sessions.

Keys also have params which can be get/set via CryptGetKeyParam/CryptSetKeyParam

## Context

CryptAcquireContext queries for both a CSP and a container within that
CSP. If successful (result code != 0) you get the handle to this
container.

This function is also reused to do *other stuff* based on an action
field (so creating & destroying containers for example)

CryptReleaseContext releases the handle.

## Hashing

- CryptCreateHash returns a handle to a CSP hash object
- CryptGetHashParam retrieves the hash value from the hash object (behavior is determined by a flag)
- CryptDestroyHash releases the handle returned from CryptCreateHash (Should really be called CryptReleaseHash or something)
- CryptHashData hash some data

## Encryption & Decryption

CryptEncrypt takes the following
- handle to `key`
- optional handle to `hash` object
- the 'last block' flag. A bool that should only be set true for the last block
- flag
- pointer to data to encrypt or null if you just want to compute the
  size of the resulting data
- &ref to size of resulting data
- number of bytes to encrypt

CryptDecrypt very similar. Not gonna go in to this here

Also the CryptProtectData functions seem useful as you can run them on
any DATA_BLOB object, which might be easier to wrap in an uno'y kind
of way

## Object Encoding/Decoding

certificates, certificate revocation lists (CRLs), certificate requests,
and certificate extensions can be encoded and decoded.

## Certificate Store

CertOpenSystemStore opens the default store (other stores are probably outside scope for v1)

'Collection Certificate Stores' are a thing, dont mix em up with containers

## MOOOORE

I've been reading this for an hour, sumarising it is hard. Will defer for now
https://msdn.microsoft.com/en-us/library/aa380252.aspx#base_cryptography_functions

# c#

The docs here are fucking shite

https://msdn.microsoft.com/en-us/library/system.security.cryptography.x509certificates.x509certificate.aspx
https://msdn.microsoft.com/en-us/library/system.net.security.sslstream(v=vs.110).aspx
https://msdn.microsoft.com/en-us/library/system.net.security.remotecertificatevalidationcallback(v=vs.110).aspx
https://msdn.microsoft.com/en-us/library/system.security.cryptography.x509certificates.x509store(v=vs.110).aspx

Gonna have to piece all this together from the reference docs. What a pain the the gooch

Ah maybe this will help https://docs.microsoft.com/en-us/dotnet/standard/security/cryptography-model

Still blown away that their c++ docs are better than their c# ones.

# wat

private key -v- secret key
