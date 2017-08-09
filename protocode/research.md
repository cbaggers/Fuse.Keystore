# Android

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

DER file is unencypted by PKCS is meant to be secure and can be loaded into the keychain

The opaque SecCertificateRef type seems to be what is used most places in the api (except for exchange format naturally)

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

## Certificate extensions

Additional information and conditions, like acceptable uses for the public key

# wat

private key -v- secret key

