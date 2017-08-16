using Uno;
using Fuse.Scripting;
using Uno.Collections;
using Uno.Threading;

namespace Fuse.Security
{
    extern(!android && !iOS && !MSVC12)
    internal class GetCertificateFromKeyStore : Promise<Certificate>
    {
        public GetCertificateFromKeyStore(string name)
        {
            Reject(new Exception("GetCertificateFromKeyStore is not implemented on this platform"));
        }
    }
}
