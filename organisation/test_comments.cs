using System;

namespace TestNamespace
{
  /// <summary>
  /// This is a test class with various types of comments
  /// </summary>
  public class TestClass
  {
    // Another standalone comment at the end

    // Fields
    // This is a field comment
    private int testField;

    // Properties
    /* Multi-line comment
           for a property */
    public string TestProperty { get; set; }

    // Public Methods
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

  }
}
