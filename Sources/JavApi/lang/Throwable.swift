/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
// TODO: Implementation of Throwable is an "incubation"
/// Mapping of Java exception handling
public enum Throwable : Error {
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case AbstractMethodError (_ message : String = "AbstractMethodError")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case ArithmeticException (_ message : String = "ArithmeticException")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case ArrayIndexOutOfBoundsException (_ offset : Int)
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case ArrayIndexOutOfBoundsException (_ offset : Int, _ message : String = "ArrayIndexOutOfBoundsException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case ArrayStoreException (_ message : String = "ArrayStoreException")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.4)
  case AssertionError (_ message : String = "AssertionError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case ClassCircularityError (_ message : String = "ClassCircularityError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case ClassCastException (_ message : String = "ClassCastException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case ClassFormatError (_ message : String = "ClassFormatError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case ClassNotFoundException (_ message : String = "ClassNotFoundException")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case CloneNotSupportedException (_ message : String = "CloneNotSupportedException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case Error (_ message : String = "Error")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case Exception (_ message : String = "Exception")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case IllegalAccessError (_ message : String = "IllegalAccessError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case IllegalAccessException (_ message : String = "IllegalAccessException")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case IllegalArgumentException (_ message : String = "IllegalArgumentException")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case IllegalMonitorStateException (_ message : String = "IllegalMonitorStateException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case IllegalThreadStateException (_ message : String = "IllegalThreadStateException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case IncompatibleClassChangeError (_ message : String = "IncompatibleClassChangeError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case InstantiationError (_ message : String = "InstantiationError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case InternalError (_ message : String = "InternalError")
  /// - Since: JavaApi &lt; 0.19.2 (Java 9.0)
  case IndexOutOfBoundsException (_ withValue : Int)
  /// - Since: JavaApi &gt; 0.19.2 (Java 16.0)
  /// - Note: As result of implementation way in swift, we add a ignored parameter to be different to `case` with `Int` value
  case IndexOutOfBoundsException (_ withLongValue : Int64, _ignored : Bool = true)
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case IndexOutOfBoundsException (_ withValue : Int = 0, String = "IndexOutOufBoundsException")
  
  /// - Since: JavaApi &lt; 0.16.0 (Java 9.0)
  @available(*, deprecated, renamed: "IndexOutOfBoundsException", message: "use IndexOutOfBoundsException instead and spell correctly")
  case IndexOutOufBoundsException (_ withValue : Int)
  /// - Since: JavaApi &gt; 0.16.0 (Java 16.0)
  /// - Note: As result of implementation way in swift, we add a ignored parameter to be different to `case` with `Int` value
  @available(*, deprecated, renamed: "IndexOutOfBoundsException", message: "use IndexOutOfBoundsException instead and spell correctly")
  case IndexOutOufBoundsException (_ withLongValue : Int64, _ignored : Bool = true)
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  @available(*, deprecated, renamed: "IndexOutOfBoundsException", message: "use IndexOutOfBoundsException instead and spell correctly")
  case IndexOutOufBoundsException (_ withValue : Int = 0, String = "IndexOutOufBoundsException")
  
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case LinkageError (_ message : String = "LinkageError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case InstantiationException (_ message : String = "InstantiationException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case InterruptedException (_ message : String = "InterruptedException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case NegativeArraySizeException (_ message : String = "NegativeArraySizeException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case NoClassDefFoundError (_ message : String = "NoClassDefFoundError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case NoSuchFieldError (_ message : String = "NoSuchFieldError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case NoSuchMethodError (_ message : String = "NoSuchMethodError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case NoSuchMethodException (_ message : String = "NoSuchMethodException")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case NullPointerException (_ message : String = "NullPointerExeception")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case NumberFormatException (_ message : String = "NumberFormatException")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case OutOfMemoryError (_ message : String = "OutOfMemoryError")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case RuntimeException (_ message : String = "RuntimeException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case SecurityException (_ message : String = "SecurityException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case StackOverflowError (_ message : String = "StackOverflowError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case StringIndexOutOfBoundsException (_ offset : Int)
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case StringIndexOutOfBoundsException (_ offset : Int, _ message : String = "StringIndexOutOfBoundsException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case ThreadDeath (_ message : String = "ThreadDeath")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case UnknownError (_ message : String = "UnknownError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case UnsatisfiedLinkError (_ message : String = "UnsatisfiedLinkError")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.2)
  case UnsupportedOperationException (_ message : String = "UnsupportedOperationException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case VerifyError (_ message : String = "VerifyError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case VirtualMachineError (_ message : String = "VirtualMachineError")

  // MARK: removed at once in time
  @available(*, unavailable, renamed: "java.io.UnsupportedEncodingException")
  case UnsupportedEncodingException (_ message : String = "UnsupportedEncodingException")

}

extension java.io {
  public enum Throwable : Error {
    /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
    case EOFException (_ message : String = "EOFException")
    /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
    case FileNotFoundException (_ message : String = "FileNotFoundException")
    /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
    case InterruptedIOException (_ message : String = "InterruptedIOException", byteTransferred : Int = 0)
    /// - Since: JavaApi &lt; 0.16.1 (Java 1.0)
    case IOException (_ message : String = "IOException")
    /// - Since: JavaApi &gt; 0.16.0 (Java 1.1)
    case UnsupportedEncodingException (_ message : String = "UnsupportedEncodingException")
    /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
    case UTFDataFormatException (_ message : String = "UTFDataFormatException")
  }
}

extension java.net {
  public enum Throwable : Error {
    /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
    case MalformedURLException (_ message : String = "MalformedURLException")
    /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
    case ProtocolException (_ host : String = "ProtocolException")
    /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
    case SocketException (_ message : String = "SocketException")
    /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
    case UnknownHostException (_ host : String = "UnknownHostException")
    /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
    case UnknownServiceException (_ message : String = "UnknownServiceException")
  }
}

extension java.nio {
  public enum Throwable : Error {
    /// Error, if modify only readable buffer
    case ReadOnlyBufferException
  }
}

extension java.nio.charset {
  public enum Throwable : Error {
    /// Exception if charset is not supported
    /// - Since: JavaApi &gt; 0.16.0 (Java 1.4)
    case UnsupportedCharsetException (_ name : String)
  }
}

extension java.util {
  public enum Throwable : Error {
    /// - Since: JavaApi &lt; 0.16.1 (Java 1.0)
    case EmptyStackException (_ message : String = "EmptyStackException")
    /// - Since: JavaApi &lt; 0.16.1 (Java 1.0)
    case NoSuchElementException (_ message : String = "NoSuchElementException")
  }
}

extension java.util.zip {
  public enum Throwable : Error {
    case DataFormatException (_ message : String = "DataFormatException")
  }
}
