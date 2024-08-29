/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
// TODO: Implementation of Throwable is an "incubation"
/// Mapping of Java exception handling
public enum Throwable : Error {
  case ArithmeticException (_ message : String = "ArithmeticException")
  case ArrayIndexOutOfBoundsException (_ offset : Int)
  case AssertionError (_ message : String = "AssertionError")
  case CloneNotSupportedException (_ message : String = "CloneNotSupportedException")
  case Exception (_ message : String = "Exception")
  case IllegalArgumentException (_ message : String = "IllegalArgumentException")
  case IndexOutOufBoundsException (_ withValue : Int)
  case IndexOutOufBoundsException (_ withValue : Int = 0, String = "IndexOutOufBoundsException")
  case NullPointerException (_ message : String = "NullPointerExeception")
  case NumberFormatException (_ message : String = "NumberformatException")
  case OutOfMemoryError (_ message : String = "OutOfMemoryError")
  case RuntimeException (_ message : String = "RuntimeException")
  case UnsupportedEncodingException (_ message : String = "UnsupportedEncodingException")
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
