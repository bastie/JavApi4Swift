/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
// TODO: Implementation of Throwable is an "incubation"
/// Mapping of Java exception handling
public enum Throwable : Error {
  case Exception (_ message : String = "Exception")
  case CloneNotSupportedException (_ message : String = "CloneNotSupportedException")
  case IllegalArgumentException (_ message : String = "IllegalArgumentException")
  case IndexOutOufBoundsException (_ withValue : Int)
  case NullPointerException (_ message : String = "NullPointerExeception")
  case NumberFormatException (_ message : String = "NumberformatException")
  case OutOfMemoryError (_ message : String = "OutOfMemoryError")
  case RuntimeException (_ message : String = "RuntimeException")
  case UnsupportedEncodingException (_ message : String = "UnsupportedEncodingException")
  case ArithmeticException (_ message : String = "ArithmeticException")
  case AssertionError (_ message : String = "AssertionError")
}

extension java.io {
  public enum Throwable : Error {
    case IOException (_ message : String = "IOException")
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
