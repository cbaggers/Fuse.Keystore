using Uno;
using Fuse.Scripting;
using Uno.Collections;
using Uno.Threading;

namespace Fuse.Security
{
    extern(!android && !iOS)
    public class GetCertificateChainFromKeyStore : Promise<CertificateChain>
    {
        public GetCertificateChainFromKeyStore(string name)
        {
            Reject(new Exception("GetCertificateChainFromKeyStore is not implemented on this platform"));
        }
    }

    extern(!android && !iOS)
    public class AddPKCS12ToKeyStore : Promise<bool>
    {
        public AddPKCS12ToKeyStore(string name, byte[] data)
        {
            Reject(new Exception("AddPKCS12ToKeyStore is not implemented on this platform"));
        }
    }

    extern(!android && !iOS)
    public class LoadCertificateFromBytes : Promise<Certificate>
    {
        public LoadCertificateFromBytes(byte[] data)
        {
            Reject(new Exception("LoadCertificateFromBytes is not implemented on this platform"));
        }
    }

    extern(!android && !iOS)
    public class PickCertificate : Promise<string>
    {
        public PickCertificate()
        {
            Reject(new Exception("PickCertificate is not implemented on this platform"));
        }
    }

    extern(!android && !iOS)
    public class LoadPKCS12FromBytes : Promise<Certificate>
    {
        public LoadPKCS12FromBytes(string path, string password)
        {
            Reject(new Exception("PickCertificate is not implemented on this platform"));
        }
    }
}
