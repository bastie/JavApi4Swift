/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
// TODO: Implementation of Throwable is an "incubation"
/// Mapping of Java exception handling

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
