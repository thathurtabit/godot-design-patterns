using System;

namespace TestNamespace
{
  /// <summary>
  /// This is a test class with various types of comments for regions test
  /// </summary>
  public class TestRegionsClass
  {
    // Another standalone comment at the end

    #region Fields
    // This is a field comment
    private int testField;
    #endregion

    #region Properties
    /* Multi-line comment
           for a property */
    public string TestProperty { get; set; }
    #endregion

    #region Public Methods
    // Standalone comment between members

    /// <summary>
    /// This method does something important
    /// </summary>
    /// <returns>Always true</returns>
    public bool TestMethod()
    {
      // Implementation comment inside method
      return true;
    }
    #endregion

  }
}
