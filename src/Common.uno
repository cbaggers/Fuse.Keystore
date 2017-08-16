using Uno;
using Uno.UX;
using Uno.Threading;
using Uno.Permissions;
using Fuse.Scripting;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.Security
{
    public interface Certificate
    {
        //bool IsValid { get; }
    }

    public sealed class CertificateChain
    {
        readonly List<Certificate> _certs;

        public CertificateChain(IEnumerable<Certificate> chain)
        {
            var certs = new List<Certificate>();
            certs.AddRange(chain);
            _certs = certs;
        }

        public CertificateChain(Certificate cert)
        {
            var certs = new List<Certificate>();
            certs.Add(cert);
            _certs = certs;
        }

        public Certificate this[int i]
        {
            get { return _certs[i]; }
        }
    }
}
