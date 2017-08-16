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
    extern(iOS) internal class iOSCert : Certificate
    {
        SecCertRef _handle;

        public iOSCert(SecCertRef handle)
        {
            _handle = handle;
        }

        [Foreign(Language.ObjC)]
        ~iOSCert()
        @{
            CFRelease(@{iOSCert:Of(_this)._handle});
        @}
    }

    [Require("Entity","SecCertRef")]
    extern(iOS)
    internal class GetCertificateChainFromKeyStore : Promise<CertificateChain>
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
                if (SecCertRef.IsNull(certRef))
                {
                    var cert = new iOSCert(GetCertificateImpl(name));
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
    extern(iOS)
    internal class AddPKCS12ToKeyStore : Promise<bool>
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
    extern(iOS)
    internal class LoadCertificateFromFile : Promise<Certificate>
    {
        public LoadCertificateFromFile(string path)
        {
            var data = Uno.IO.File.ReadAllBytes(path);
            var view = ForeignDataView.Create(data);
            var cert = new iOSCert(Impl(view));
            Resolve(cert);
        }

        [Foreign(Language.ObjC)]
        static SecCertRef Impl(ForeignDataView view)
        @{
            return SecCertificateCreateWithData(NULL, view);
        @}
    }
}
