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
    public extern(iOS) struct SecCertRef
    {
        IntPtr _dummy;

        public static bool IsNull(SecCertRef lhs)
        {
            return extern<bool>(lhs)"$0 == NULL";
        }
    }

    [Set("FileExtension", "mm")]
    extern(iOS) public class iOSCert : Certificate
    {
        SecCertRef _handle;

        public iOSCert(SecCertRef handle)
        {
            if (SecCertRef.IsNull(handle))
            {
                throw new Exception("SecCertRef was null couldnt make iOSCert");
            }
            else
            {
                _handle = handle;
            }
        }

        [Foreign(Language.ObjC)]
        ~iOSCert()
        @{
            CFRelease(@{iOSCert:Of(_this)._handle});
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

    [Require("Entity","SecCertRef")]
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
                if (!SecCertRef.IsNull(certRef))
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
        static SecCertRef GetCertificateImpl(string name)
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

    [Require("Entity","SecCertRef")]
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

    [Require("Entity","SecCertRef")]
    [Set("FileExtension", "mm")]
    extern(iOS)
    public class LoadCertificateFromBytes : Promise<Certificate>
    {
        public LoadCertificateFromBytes(byte[] data) : this(ForeignDataView.Create(data)) {}

        public LoadCertificateFromBytes(ForeignDataView view)
        {
            var certRef = Impl(view);
            if (!SecCertRef.IsNull(certRef))
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
        static SecCertRef Impl(ForeignDataView view)
        @{
            return SecCertificateCreateWithData(NULL, (__bridge CFDataRef)view);
        @}
    }

    [Require("Entity","SecCertRef")]
    [Set("FileExtension", "mm")]
    extern(iOS)
    public class LoadCertificateFromPKCS : Promise<Certificate>
    {
        public LoadCertificateFromPKCS(string path, string password)
        {
            var data = Uno.IO.File.ReadAllBytes(path);
            var view = ForeignDataView.Create(data);
            var certRef = Impl(view, password);
            if (!SecCertRef.IsNull(certRef))
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
        static SecCertRef Impl(ForeignDataView view, string password)
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
            CFArrayRef _Nullable* items;
            OSStatus status = SecPKCS12Import((__bridge CFDataRef)view,
                                              (__bridge CFDictionaryRef)options,
                                              items);
            if (status != 0 || items == NULL)
            {
                return NULL;
            }
            else
            {
                CFDictionaryRef ident = CFArrayGetValueAtIndex(items, 0);
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
}
