using Uno;
using Fuse.Scripting;
using Uno.Collections;

namespace Fuse.Security
{
    extern(!android && !iOS && !MSVC12) static class KeyStore
    {
        static public void Init() {}
        static public Certificate GetSomething(string name) { return null; }
    }
}
