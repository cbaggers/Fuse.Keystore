using Uno;
using Uno.IO;
using Uno.Testing;
using Uno.Threading;
using Fuse.Security;

namespace KeyStoreTests
{
    public class TrustContextPromise0 : Promise<TrustContext>
    {
        public TrustContextPromise0()
        {
            var certBytes = import BundleFile("certs/client/senderDER.crt").ReadAllBytes();
            var test = new LoadCertificateFromBytes(certBytes);
            test.Then(Succeed0, Failed);
        }

        void Succeed0(Certificate cert)
        {
            var test = new TrustContextFromCACertificate(cert);
            test.Then(Succeed1);
        }

        void Succeed1(TrustContext ctx)
        {
            Resolve(ctx);
        }

        void Failed(Exception e)
        {
            Reject(e);
        }
    }

    public class TrustContextTests
    {
        [Test]
        public void TrustContext0()
        {
            FutureTest<TrustContext>.Execute(new TrustContextPromise0(), Should.Succeed);
        }
    }
}
