using Uno;
using Uno.UX;
using Uno.Threading;
using Uno.Permissions;
using Fuse.Scripting;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.Security
{
    // [ForeignInclude(Language.ObjC, "AVFoundation/AVFoundation.h")]
    // [Require("Xcode.Framework", "CoreImage")]
    // [ForeignInclude(Language.ObjC, "CoreImage/CoreImage.h")]
    extern(iOS) static class KeyStore
    {
        static public void Init() {}

        [Foreign(Language.ObjC)]
        static public void GetSomething()
        @{
        @}
    }
}
