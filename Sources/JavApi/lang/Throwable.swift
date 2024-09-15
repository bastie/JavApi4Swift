/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
// TODO: Implementation of Throwable is an "incubation"
/// Mapping of Java exception handling
public enum Throwable : Error {
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case AbstractMethodError (_ message : String = "AbstractMethodError")
  case ArithmeticException (_ message : String = "ArithmeticException")
  case ArrayIndexOutOfBoundsException (_ offset : Int)
  case ArrayIndexOutOfBoundsException (_ offset : Int, _ message : String = "ArrayIndexOutOfBoundsException")
  case AssertionError (_ message : String = "AssertionError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case ClassCircularityError (_ message : String = "ClassCircularityError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case ClassFormatError (_ message : String = "ClassFormatError")
  case CloneNotSupportedException (_ message : String = "CloneNotSupportedException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case Error (_ message : String = "Error")
  case Exception (_ message : String = "Exception")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case IllegalAccessError (_ message : String = "IllegalAccessError")
  case IllegalArgumentException (_ message : String = "IllegalArgumentException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case IncompatibleClassChangeError (_ message : String = "IncompatibleClassChangeError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case InstantiationError (_ message : String = "InstantiationError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case InternalError (_ message : String = "InternalError")
  case IndexOutOufBoundsException (_ withValue : Int)
  case IndexOutOufBoundsException (_ withValue : Int = 0, String = "IndexOutOufBoundsException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case LinkageError (_ message : String = "LinkageError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case NoClassDefFoundError (_ message : String = "NoClassDefFoundError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case NoSuchFieldError (_ message : String = "NoSuchFieldError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case NoSuchMethodError (_ message : String = "NoSuchMethodError")
  case NullPointerException (_ message : String = "NullPointerExeception")
  case NumberFormatException (_ message : String = "NumberFormatException")
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  case OutOfMemoryError (_ message : String = "OutOfMemoryError")
  case RuntimeException (_ message : String = "RuntimeException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case StackOverflowError (_ message : String = "StackOverflowError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case ThreadDeath (_ message : String = "ThreadDeath")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case UnknownError (_ message : String = "UnknownError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case UnsatisfiedLinkError (_ message : String = "UnsatisfiedLinkError")
  case UnsupportedEncodingException (_ message : String = "UnsupportedEncodingException")
  case UnsupportedOperationException (_ message : String = "UnsupportedOperationException")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case VerifyError (_ message : String = "VerifyError")
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  case VirtualMachineError (_ message : String = "VirtualMachineError")
}

extension java.io {
  public enum Throwable : Error {
    case IOException (_ message : String = "IOException")
  }
}

extension java.nio {
  public enum Throwable : Error {
    /// Error, if modify only readable buffer
    case ReadOnlyBufferException
  }
}

extension java.util {
  public enum Throwable : Error {
    case EmptyStackException (_ message : String = "EmptyStackException")
    case NoSuchElementException (_ message : String = "NoSuchElementException")
  }
}

extension java.util.zip {
  public enum Throwable : Error {
    case DataFormatException (_ message : String = "DataFormatException")
  }
}
