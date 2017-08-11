using Uno;
using Uno.UX;
using Uno.Threading;
using Uno.Permissions;
using Fuse.Scripting;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.Security
{
    [ForeignInclude(Language.Java,
                    "java.lang.Exception",
                    "android.app.Activity")]
    extern(Android) static class KeyStore
    {
        static public void Init() {}

        [Foreign(Language.Java)]
        static public Certificate GetSomething(string name)
        @{
        @}
    }
}
