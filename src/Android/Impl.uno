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
    extern(Android) internal class AndCert : Certificate
    {
        Java.Object _handle;
        bool _valid;
        bool _validated;

        public AndCert(Java.Object handle)
        {
            _handle = handle;
            _validated = false;
        }

        public bool Valid
        {
            get
            {
                if (!_validated)
                {
                    _valid = Validate(_handle);
                }
                return _valid;
            }
        }

        [Foreign(Language.Java)]
        static bool Validate(Java.Object cert)
        @{
            return false;
        @}
    }

    [ForeignInclude(Language.Java,
                    "java.lang.Exception",
                    "android.security.KeyChain",
                    "java.security.cert.X509Certificate",
                    "android.app.Activity")]
    extern(android)
    internal class GetCertificateFromKeyStore : Promise<Certificate>
    {
        [Foreign(Language.Java)]
        public GetCertificateFromKeyStore(string name)
        @{
            if (name == null)
            {
                @{GetCertificateFromKeyStore:Of(_this).Reject(string):Call("GetCertificateFromKeyStore requires that the certificate name is provided")};
                return;
            }

            new AsyncTask<Void, Void, Void> ()
            {
                @Override
                protected Void doInBackground(Void... voids)
                {
                    try
                    {
                        X509Certificate[] chain = KeyChain.getCertificateChain(com.fuse.Activity.getRootActivity(), name);
                        UnoObject cert = @{AndCert(Java.Object):New(chain)};
                        @{GetCertificateFromKeyStore:Of(_this).Resolve(Certificate):Call(cert)};
                    }
                    catch (Exception e)
                    {
                        @{GetCertificateFromKeyStore:Of(_this).Reject(string):Call("Could not aquire certificate with name '" + name + "'\nReason" + e.getMessage())};
                    }
                    return null;
                }
            }.execute();
        @}
        void Reject(string reason) { Reject(new Exception(reason)); }
    }
}
