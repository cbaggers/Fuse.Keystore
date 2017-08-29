using Uno;
using Uno.IO;
using Uno.Testing;
using Uno.Threading;
using Fuse.Security;

namespace KeyStoreTests
{
    public class CertTests
    {
        [Test]
        public void LoadCertFromBytes0()
        {
            var certBytes = import BundleFile("certs/client/senderDER.crt").ReadAllBytes();
            FutureTest<Certificate>.Execute(new LoadCertificateFromBytes(certBytes), Should.Succeed);
        }

        [Test]
        public void PickCert0()
        {
            FutureTest<string>.Execute(new PickCertificate(), Should.Succeed);
        }

        [Test]
        public void LoadPKCS12Identity0()
        {
            var pkcs12Bytes = import BundleFile("certs/client/senderDER.crt").ReadAllBytes();
            FutureTest<Certificate>.Execute(new LoadPKCS12FromBytes(pkcs12Bytes, "1234"), Should.Succeed);
        }
    }
}

// var foo = new GetCertificateChainFromKeyStore((string)args[0]);
// var bar = new AddPKCS12ToKeyStore(null, null);
// var biscuits = Helpers.LoadCertificateFromFile("foo.crt");
// var mast = new PickCertificate();
