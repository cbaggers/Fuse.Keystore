using Uno;
using Uno.UX;
using Uno.Threading;
using Uno.Permissions;
using Fuse.Scripting;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Uno.Threading;

namespace Fuse.Security
{
    [Require("Xcode.Framework", "Security.framework")]
    [Require("Source.Include", "Security/Security.h")]
    [Set("Include", "Security/Security.h")]
    [Set("TypeName", "SecCertificateRef")]
    [Set("DefaultValue", "NULL")]
    [Set("FileExtension", "mm")]
    [TargetSpecificType]
    public extern(iOS) struct SecCertHandle
    {
        public static bool IsNull(SecCertHandle lhs)
        {
            return extern<bool>(lhs)"$0 == NULL";
        }
    }

    [Require("Xcode.Framework", "Security.framework")]
    [Require("Source.Include", "Security/Security.h")]
    [Set("Include", "Security/Security.h")]
    [Set("TypeName", "SecTrustRef")]
    [Set("DefaultValue", "NULL")]
    [Set("FileExtension", "mm")]
    [TargetSpecificType]
    public extern(iOS) struct SecTrustHandle
    {
        public static bool IsNull(SecTrustHandle lhs)
        {
            return extern<bool>(lhs)"$0 == NULL";
        }
    }


    extern(iOS)
    public class iOSTrustContext : TrustContext
    {
        SecTrustHandle _handle;

        public iOSTrustContext(SecTrustHandle handle)
        {
            if (SecTrustHandle.IsNull(handle))
            {
                throw new Exception("SecTrustHandle was null couldnt make iOSCert");
            }
            else
            {
                _handle = handle;
            }
        }

        ~iOSTrustContext()
        {
            // Impl is in static function as otherwise tries to take ref to _this in a way which
            // causes an exception as we are in the uno destructor codepath
            ReleaseHandle(_handle);
        }

        [Foreign(Language.ObjC)]
        static void ReleaseHandle(SecTrustHandle handle)
        @{
            CFRelease(handle);
        @}
    }


    [Set("FileExtension", "mm")]
    extern(iOS) public class iOSCert : Certificate
    {
        SecCertHandle _handle;

        public iOSCert(SecCertHandle handle)
        {
            if (SecCertHandle.IsNull(handle))
            {
                throw new Exception("SecCertHandle was null couldnt make iOSCert");
            }
            else
            {
                _handle = handle;
            }
        }

        ~iOSCert()
        {
            ReleaseCert(_handle);
        }

        [Foreign(Language.ObjC)]
        static void ReleaseCert(SecCertHandle handle)
        @{
            CFRelease(handle);
        @}

        [Foreign(Language.Java)]
        public string Subject
        {
            get
            @{
                // ARC takes ownership
                return (NSString*)CFBridgingRelease(SecCertificateCopySubjectSummary(@{_handle}));
            @}
        }
    }


    [Require("Entity","SecCertHandle")]
    [Set("FileExtension", "mm")]
    extern(iOS)
    public class GetCertificateChainFromKeyStore : Promise<CertificateChain>
    {
        public GetCertificateChainFromKeyStore(string name)
        {
            if (name == null)
            {
                Reject(new Exception("GetCertificateChainFromKeyStore requires that the certificate name is provided"));
            }
            else
            {
                var certRef = GetCertificateImpl(name);
                if (!SecCertHandle.IsNull(certRef))
                {
                    var cert = new iOSCert(certRef);
                    Resolve(new CertificateChain(cert));
                }
                else
                {
                    Reject(new Exception("Could not aquire certificate with name '" + name));
                }
            }
        }

        [Foreign(Language.ObjC)]
        static SecCertHandle GetCertificateImpl(string name)
        @{
            NSDictionary *getquery =
                @{ (id)kSecClass:     (id)kSecClassCertificate,
                   (id)kSecAttrLabel: name,
                   (id)kSecReturnRef: @YES,
                };

            SecCertificateRef certificate = NULL;
            OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)getquery,
                                                  (CFTypeRef *)&certificate);

            if (status != errSecSuccess)
            {
                return nil;
            }
            else
            {
                return certificate;
            }
        @}
    }


    [Require("Entity","SecCertHandle")]
    [Set("FileExtension", "mm")]
    extern(iOS)
    public class AddPKCS12ToKeyStore : Promise<bool>
    {
        public AddPKCS12ToKeyStore(string name, byte[] data)
        {
            if (name == null || data == null)
            {
                Reject(new Exception("AddPKCS12ToKeyStore requires that the name & data are provided"));
            }
            else
            {
                Impl(name, data);
                // if ()
                // {
                //     Resolve(new iOSCert(Impl(name, data)));
                // }
                // else
                // {
                //     Reject(new Exception("Could not aquire certificate with name '" + name));
                // }
            }
        }

        [Foreign(Language.ObjC)]
        static void Impl(string name, byte[] data)
        @{
        @}
    }

    [Require("Entity","SecCertHandle")]
    [Set("FileExtension", "mm")]
    extern(iOS)
    public class LoadCertificateFromBytes : Promise<Certificate>
    {
        public LoadCertificateFromBytes(byte[] data) : this(ForeignDataView.Create(data)) {}

        public LoadCertificateFromBytes(ForeignDataView view)
        {
            var certRef = Impl(view);
            if (!SecCertHandle.IsNull(certRef))
            {
                var cert = new iOSCert(certRef);
                Resolve(cert);
            }
            else
            {
                Reject(new Exception("LoadCertificateFromBytes Failed. Certificate was null"));
            }
        }

        [Foreign(Language.ObjC)]
        static SecCertHandle Impl(ForeignDataView view)
        @{
            return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)view);
        @}
    }


    [Require("Entity","SecCertHandle")]
    [Set("FileExtension", "mm")]
    extern(iOS)
    public class LoadPKCS12FromBytes : Promise<Certificate>
    {
        public LoadPKCS12FromBytes(byte[] data, string password)
        {
            var view = ForeignDataView.Create(data);
            var certRef = Impl(view, password);
            if (!SecCertHandle.IsNull(certRef))
            {
                var cert = new iOSCert(certRef);
                Resolve(cert);
            }
            else
            {
                Reject(new Exception("LoadCertificateFromPKCS Failed. Certificate was null"));
            }
        }

        [Foreign(Language.ObjC)]
        static SecCertHandle Impl(ForeignDataView view, string password)
        @{
            NSDictionary* options =
                @{ // A passphrase (represented by a CFStringRef object) to be
                   // used when exporting to or importing from PKCS#12 format.
                   (id)kSecImportExportPassphrase: password,

                   // A keychain represented by a SecKeychainRef to be used as
                   // the target when importing or exporting.
                   // (id)kSecImportExportKeychain: …,

                   // An initial access control list represented by a SecAccessRef object.
                   // (id)kSecImportExportAccess: …,
                };
<            CFArrayRef items;
            OSStatus status = SecPKCS12Import((__bridge CFDataRef)view,
                                              (__bridge CFDictionaryRef)options,
                                              &items);
            if (status != 0 || items == NULL)
            {
                return NULL;
            }
            else
            {
                CFDictionaryRef ident = (CFDictionaryRef)CFArrayGetValueAtIndex(items, 0);
                const void* tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
                return (SecIdentityRef)tempIdentity;
            }
        @}
    }

    [Set("FileExtension", "mm")]
    extern(iOS)
    public class PickCertificate : Promise<string>
    {
        public PickCertificate()
        {
            Reject(new Exception("PickCertificate is not implemented on this platform"));
        }
    }

    [Require("Entity","SecTrustHandle")]
    [Require("Source.Include", "@{iOSCert:Include}")]
    [Set("FileExtension", "mm")]
    extern(iOS)
    public class TrustContextFromCACertificate : Promise<TrustContext>
    {
        public TrustContextFromCACertificate(Certificate cert)
        {
            var trustRef = Impl(cert);
            if (!SecTrustHandle.IsNull(trustRef))
            {
                var trust = new iOSTrustContext(trustRef);
                Resolve(trust);
            }
            else
            {
                Reject(new Exception("LoadCertificateFromPKCS Failed. Certificate was null"));
            }
        }

        [Foreign(Language.ObjC)]
        static SecTrustHandle Impl(Certificate cert)
        @{
            // Make the chain. By only providing the one cert the system will
            // search it's own cert stores for the rest
            SecCertificateRef caCert = (SecCertificateRef)@{iOSCert:Of(cert)._handle};
            NSArray* certArray = @[ (__bridge id)caCert ];

            // create a policy
            SecPolicyRef policy = SecPolicyCreateBasicX509();

            // create the trust object
            SecTrustRef trust = NULL;
            OSStatus status = SecTrustCreateWithCertificates((__bridge CFTypeRef)certArray, policy, &trust);
            if (policy) { CFRelease(policy); }   // Done with the policy object

            //
            if (status == errSecSuccess)
            {
                return trust;
            }
            else
            {
                return NULL;
            }
        @}
    }
}
