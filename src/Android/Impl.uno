using Uno;
using Uno.UX;
using Uno.Threading;
using Uno.Permissions;
using Fuse.Scripting;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.Security
{
    extern(Android) internal class AndCert : Certificate
    {
        Java.Object _handle;

        public AndCert(Java.Object handle)
        {
            _handle = handle;
        }
    }

    [ForeignInclude(Language.Java,
                    "java.lang.Exception",
                    "android.security.KeyChain",
                    "java.security.cert.X509Certificate",
                    "android.app.Activity")]
    extern(Android) static class KeyStore
    {
        static public void Init() {}

        [Foreign(Language.Java)]
        static public Certificate GetCertificate(string name)
        @{
            try
            {
                X509Certificate[] chain = KeyChain.getCertificateChain(com.fuse.Activity.getRootActivity(), name);
                return @{AndCert(Java.Object):New(chain)};
            }
            catch (Exception e)
            {
                return null;
            }
        @}
    }
}
