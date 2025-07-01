using System;

namespace TestNamespace
{
    public class UnorganizedTestClass
    {
        public string TestProperty { get; set; }
        
        private int _testField;
        
        public void TestMethod()
        {
            Console.WriteLine("Test");
        }
        
        private void PrivateMethod()
        {
            // Implementation
        }
    }
}
