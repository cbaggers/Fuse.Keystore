using Uno;
using Fuse.Scripting;
using Uno.Collections;

namespace Fuse.Security
{
    extern(MSVC12)
    internal class GetCertificateChainFromKeyStore : Promise<CertificateChain>
    {
        public GetCertificateChainFromKeyStore(string name)
        {
            Reject(new Exception("GetCertificateChainFromKeyStore is not implemented on this platform"));
        }
    }

    extern(MSVC12)
    internal class AddPKCS12ToKeyStore : Promise<bool>
    {
        public AddPKCS12ToKeyStore(string name, byte[] data)
        {
            Reject(new Exception("AddPKCS12ToKeyStore is not implemented on this platform"));
        }
    }
}
