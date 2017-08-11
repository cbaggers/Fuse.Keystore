using Uno;
using Uno.UX;
using Uno.Threading;
using Uno.Permissions;
using Fuse.Scripting;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;

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
    extern(iOS) static class KeyStore
    {
        static public void Init() {}

        static public Certificate GetSomething(string name)
        {
            return new iOSCert(GetSomethingImpl(name));
        }

        [Foreign(Language.ObjC)]
        static public SecCertRef GetSomethingImpl(string name)
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
