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
    public extern(iOS) struct SecCertRef {  IntPtr _dummy; }

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
    internal class GetCertificateFromKeyStore : Promise<Certificate>
    {
        public GetCertificateFromKeyStore(string name)
        {
            if (name == null)
            {
                Reject(new Exception("GetCertificateFromKeyStore requires that the certificate name is provided"));
            }
            else
            {
                var foo = GetCertificateImpl(name);
                if (foo!=null)
                {
                    Resolve(new iOSCert(GetCertificateImpl(name)));
                }
                else
                {
                    Reject(new Exception("Could not aquire certificate with name '" + name));
                }
            }

        }

        [Foreign(Language.ObjC)]
        static public SecCertRef GetCertificateImpl(string name)
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
}
