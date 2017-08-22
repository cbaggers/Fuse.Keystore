using Uno;
using Fuse.Scripting;
using Uno.Collections;
using Uno.Threading;

namespace Fuse.Security
{
    extern(!android && !iOS)
    internal class GetCertificateChainFromKeyStore : Promise<CertificateChain>
    {
        public GetCertificateChainFromKeyStore(string name)
        {
            Reject(new Exception("GetCertificateChainFromKeyStore is not implemented on this platform"));
        }
    }

    extern(!android && !iOS)
    internal class AddPKCS12ToKeyStore : Promise<bool>
    {
        public AddPKCS12ToKeyStore(string name, byte[] data)
        {
            Reject(new Exception("AddPKCS12ToKeyStore is not implemented on this platform"));
        }
    }

    extern(!android && !iOS)
    internal class LoadCertificateFromFile : Promise<Certificate>
    {
        public LoadCertificateFromFile(string path)
        {
            Reject(new Exception("LoadCertificateFromFile is not implemented on this platform"));
        }
    }

    extern(!android && !iOS)
    internal class PickCertificate : Promise<string>
    {
        public PickCertificate()
        {
            Reject(new Exception("PickCertificate is not implemented on this platform"));
        }
    }

    extern(!android && !iOS)
    internal class LoadCertificateFromPKCS : Promise<Certificate>
    {
        public LoadCertificateFromPKCS(string path, string password)
        {
            Reject(new Exception("PickCertificate is not implemented on this platform"));
        }
    }
}
