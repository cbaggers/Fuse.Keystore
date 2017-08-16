using Uno;
using Fuse.Scripting;
using Uno.Collections;

namespace Fuse.Security
{
    extern(MSVC12)
    internal class GetCertificateFromKeyStore : Promise<Certificate>
    {
        public GetCertificateFromKeyStore(string name)
        {
            Reject(new Exception("GetCertificateFromKeyStore is not implemented on this platform"));
        }
    }
}
