using Uno;
using Uno.IO;
using Uno.Testing;
using Uno.Threading;
using Fuse.Security;

namespace KeyStoreTests
{
    public enum Should { Succeed, Fail }

    public class FutureTest<T>
    {
        Future<T> _future;
        T _value;
        Exception _exception;
        Should _expected;
        bool _passed;

        public FutureTest(Future<T> future, Should expected)
        {
            _future = future;
            _expected = expected;
            future.Then(OnSucceed, OnFail);
        }

        void OnSucceed(T val)
        {
            _passed = _expected == Should.Succeed;
            _value = val;
        }

        void OnFail(Exception ex)
        {
            _passed = _expected == Should.Fail;
            _exception = ex;
        }

        public void Resolve()
        {
            _future.Wait();
            if (_passed)
            {
                debug_log("-- Test Passed: " + _value);
            }
            else
            {
                debug_log("-- Test Fail: " + (_exception!=null ? _exception.Message : ""));
            }
            Assert.IsTrue(_passed);
        }

        public static void Execute(Future<T> future, Should expected)
        {
            var test = new FutureTest<T>(future, expected);
            test.Resolve();
        }
    }
}
