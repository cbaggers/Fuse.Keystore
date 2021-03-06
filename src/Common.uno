using Uno;
using Uno.UX;
using Uno.Threading;
using Uno.Permissions;
using Fuse.Scripting;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.Security
{
    public interface TrustContext {}

    public interface Certificate
    {
        string Subject { get; }
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

    public static class Helpers
    {
        public static Promise<Certificate> LoadCertificateFromFile(string path)
        {
            var data = Uno.IO.File.ReadAllBytes(path);
            return new LoadCertificateFromBytes(data);
        }

        public static Promise<Certificate> LoadPKCS12FromFile(string path, string password)
        {
            var data = Uno.IO.File.ReadAllBytes(path);
            return new LoadPKCS12FromBytes(data, password);
        }
    }
}
