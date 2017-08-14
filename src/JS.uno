using Uno;
using Uno.UX;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Fuse;
using Fuse.Platform;
using Fuse.Scripting;

namespace Fuse.Security
{
    [UXGlobalModule]
    public class KeyStoreModule : NativeEventEmitterModule
    {
        static KeyStoreModule _instance;

        public KeyStoreModule(): base(true)
        {
            if (_instance != null) return;
            _instance = this;

            KeyStore.Init();

            AddMember(new NativeFunction("something", (NativeCallback)Something));
            Resource.SetGlobalKey(_instance, "FuseJS/KeyStore");
        }

        public object Something(Context c, object[] args)
        {
            KeyStore.GetCertificate((string)args[0]);
            return null;
        }
    }
}
