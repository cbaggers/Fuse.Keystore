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
    [ForeignInclude(Language.Java,
                    "java.security.cert.X509Certificate")]
    extern(android)
    public class AndroidCertificate : Certificate
    {
        Java.Object _handle;

        public AndroidCertificate(Java.Object handle)
        {
            _handle = handle;
        }


        public string Subject
        {
            get { return GetSubject(_handle); }
        }

        [Foreign(Language.Java)]
        static string GetSubject(Java.Object handle)
        @{
            X509Certificate cert = (X509Certificate)handle;
            return cert.getSubjectDN().getName();
        @}
    }

    [ForeignInclude(Language.Java,
                    "java.lang.Exception",
                    "android.security.KeyChain",
                    "java.security.cert.X509Certificate",
                    "android.app.Activity",
                    "android.os.AsyncTask")]
    extern(android)
    public class GetCertificateChainFromKeyStore : Promise<CertificateChain>
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
            _wip.Add(new AndroidCertificate(cert));
        }

        void Resolve() { Resolve(new CertificateChain(_wip)); }

        void Reject(string reason) { Reject(new Exception(reason)); }
    }


    [ForeignInclude(Language.Java,
                    "android.security.KeyChain",
                    "android.content.Intent")]
    extern(android)
    public class AddPKCS12ToKeyStore : Promise<bool>
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


    [ForeignInclude(Language.Java,
                    "java.io.InputStream",
                    "java.security.cert.CertificateFactory",
                    "java.security.cert.X509Certificate")]
    extern(android)
    public class LoadCertificateFromBytes : Promise<Certificate>
    {
        public LoadCertificateFromBytes(byte[] data)
        {
            var buf = ForeignDataView.Create(data);
            var inputStream = MakeBufferInputStream(buf);
            LoadCertificateFromInputStream(inputStream);
        }

        [Foreign(Language.Java)]
        static Java.Object MakeBufferInputStream(Java.Object buf) // UnoBackedByteBuffer buf
        @{
            return new com.fuse.android.ByteBufferInputStream((com.uno.UnoBackedByteBuffer)buf);
        @}

        [Foreign(Language.Java)]
        void LoadCertificateFromInputStream(Java.Object inputStream)
        @{
            try
            {
                CertificateFactory fact = CertificateFactory.getInstance("X.509");
                X509Certificate cer = (X509Certificate)fact.generateCertificate((InputStream)inputStream);
                @{LoadCertificateFromBytes:Of(_this).Resolve(Java.Object):Call(cer)};
            }
            catch (Exception e)
            {
                @{LoadCertificateFromBytes:Of(_this).Reject(string):Call("Could not load certificate from byte\nReason" + e.getMessage())};
            }
        @}

        void Resolve(Java.Object cert) { Resolve(new AndroidCertificate(cert)); }
        void Reject(string reason) { Reject(new Exception(reason)); }
    }

    [ForeignInclude(Language.Java,
                    "java.security.Principal",
                    "android.security.KeyChain",
                    "android.security.KeyChainAliasCallback")]
    extern(android)
    public class PickCertificate : Promise<string>
    {
        [Foreign(Language.Java)]
        public PickCertificate()
        @{
            final String[] keyTypes = null;
            final Principal[] issuers = null;
            final String host = null;
            final int port = -1;
            final String preselectAlias = null;
            KeyChain.choosePrivateKeyAlias(com.fuse.Activity.getRootActivity(),
                new KeyChainAliasCallback()
                {
                    @Override public void alias(String alias)
                    {
                        if (alias == null)
                        {
                            @{PickCertificate:Of(_this).Reject(string):Call("Cancelled")};
                        }
                        else
                        {
                            @{PickCertificate:Of(_this).Resolve(string):Call(alias)};
                        }
                    }
                }, keyTypes, issuers, host, port, preselectAlias);
        @}

        void Reject(string reason) { Reject(new Exception(reason)); }
    }

    extern(android)
    public class LoadCertificateFromPKCS : Promise<Certificate>
    {
        public LoadCertificateFromPKCS(string path, string password)
        {
            Reject(new Exception("PickCertificate is not implemented on this platform"));
        }
    }
}
