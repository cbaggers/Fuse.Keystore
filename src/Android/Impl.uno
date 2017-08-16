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
    extern(android) internal class AndCert : Certificate
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
                    "android.app.Activity",
                    "android.os.AsyncTask")]
    extern(android)
    internal class GetCertificateChainFromKeyStore : Promise<CertificateChain>
    {
        List<Certificate> _wip = new List<Certificate>();

        [Foreign(Language.Java)]
        public GetCertificateChainFromKeyStore(string name)
        @{
            if (name == null)
            {
                @{GetCertificateChainFromKeyStore:Of(_this).Reject(string):Call("GetCertificateChainFromKeyStore requires that the certificate name is provided")};
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

                        for (X509Certificate cert: chain)
                        {
                            @{GetCertificateChainFromKeyStore:Of(_this).AddCert(Java.Object):Call(cert)};
                        }

                        @{GetCertificateChainFromKeyStore:Of(_this).Resolve():Call()};
                    }
                    catch (Exception e)
                    {
                        @{GetCertificateChainFromKeyStore:Of(_this).Reject(string):Call("Could not aquire certificate with name '" + name + "'\nReason" + e.getMessage())};
                    }
                    return null;
                }
            }.execute();
        @}

        void AddCert(Java.Object cert)
        {
            _wip.Add(new AndCert(cert));
        }

        void Resolve() { Resolve(new CertificateChain(_wip)); }

        void Reject(string reason) { Reject(new Exception(reason)); }
    }


    [ForeignInclude(Language.Java,
                    "android.security.KeyChain",
                    "android.content.Intent")]
    extern(android)
    internal class AddPKCS12ToKeyStore : Promise<bool>
    {
        public AddPKCS12ToKeyStore(string name, byte[] data)
        {
            if (name == null || data == null)
            {
                Reject("AddPKCS12ToKeyStore requires that the name & data are provided");
            }
            else
            {
                global::Android.ActivityUtils.StartActivity(MakeIntent(name, data), onResult);
            }
        }

        [Foreign(Language.Java)]
        void onResult(int resultCode, Java.Object intent, object info)
        @{
            if (resultCode == android.app.Activity.RESULT_OK)
            {
                @{AddPKCS12ToKeyStore:Of(_this).Resolve(bool):Call(true)};
            }
            else
            {
                @{AddPKCS12ToKeyStore:Of(_this).Reject(string):Call("Certificate install failed")};
            }
        @}

        void Reject(string reason) { Reject(new Exception(reason)); }

        [Foreign(Language.Java)]
        Java.Object MakeIntent(string name, byte[] data)
        @{
            final byte[] keystore = data.copyArray();
            Intent installIntent = KeyChain.createInstallIntent();
            installIntent.putExtra(KeyChain.EXTRA_PKCS12, keystore);
            return installIntent;
        @}
    }
}
