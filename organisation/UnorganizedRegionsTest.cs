using System;

namespace TestNamespace
{
  public class UnorganizedRegionsTest
  {
    #region Fields
    private string _testField;
    #endregion

    #region Properties
    public bool TestProperty { get; set; }
    #endregion

    #region Public Methods
    public void TestMethod()
    {
      Console.WriteLine("Test");
    }
    #endregion

    #region Private Methods
    private void PrivateMethod()
    {
      // Implementation
    }
    #endregion
  }
}
