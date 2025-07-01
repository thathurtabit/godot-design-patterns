using System;

namespace TestNamespace
{
    public class UnorganizedRegionsTest
    {
        public bool TestProperty { get; set; }
        
        private string _testField;
        
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
