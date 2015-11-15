using System.Runtime.InteropServices;

namespace TestCOMObject
{
    [Guid("7068AC34-DBB0-4e40-84A7-C2243355E2D7"),
    InterfaceType(ComInterfaceType.InterfaceIsIDispatch), ComVisible(true)]
    public interface IComClassExample
    {
        [DispId(1)]
        string GetText();
    }

    [Guid("863AEADA-EE73-4f4a-ABC0-3FB384CB41AA"),
    ClassInterface(ClassInterfaceType.None), ComVisible(true), ProgId("COMObject.ComClassExample")]
    public class ComClassExample : IComClassExample
    {
        // constructor - does nothing in this example
        public ComClassExample() { }

        // a method that returns an int
        public string GetText()
        {
            return "Hello World";
        }
    }
}
