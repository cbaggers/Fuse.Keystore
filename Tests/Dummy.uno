using Uno;
using Uno.IO;
using Uno.Testing;
using Fuse.Security;

namespace KeyStoreTests
{
    public class CertTests
    {
        [Test]
        public void LoadFromBytes0()
        {
            var certBytes = import BundleFile("certs/client/sender.crt").ReadAllBytes();
            var promise = new LoadCertificateFromBytes(certBytes);
            promise.Then(ShouldSucceed, ShouldntFail);
        }

        void ShouldSucceed(Certificate cert)
        {
            Assert.IsTrue(cert!=null);
        }

        void ShouldntFail(Exception ex)
        {
            Assert.AreEqual(1, 0);
        }
    }
}

// var foo = new GetCertificateChainFromKeyStore((string)args[0]);
// var bar = new AddPKCS12ToKeyStore(null, null);
// var biscuits = Helpers.LoadCertificateFromFile("foo.crt");
// var mast = new PickCertificate();
