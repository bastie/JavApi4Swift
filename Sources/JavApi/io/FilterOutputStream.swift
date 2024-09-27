/*
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

/**
 * Wraps an existing ``java.io.OutputStream`` and performs some transformation on
 * the output data while it is being written. Transformations can be anything
 * from a simple byte-wise filtering output data to an on-the-fly compression or
 * decompression of the underlying stream. Output streams that wrap another
 * output stream and provide some additional functionality on top of it usually
 * inherit from this class.
 *
 * - see ``java.io.FilterOutputStream``
 */
/// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
open class FilterOutputStream : java.io.OutputStream {
  
  /**
   * The target output stream for this filter stream.
   */
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  public var out : java.io.OutputStream
  
  /**
   * Constructs a new `FilterOutputStream` with `out` as its
   * target stream.
   *
   * - Parameter out
   *            the target stream that this stream writes to.
   */
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  public init(_ out : java.io.OutputStream) {
    self.out = out;
  }
  
  /**
   * Closes this stream. This implementation closes the target stream.
   *
   * - throws IOException
   *             if an error occurs attempting to close this stream.
   */
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  public override func close() throws {
    try flush();
    try out.close();
  }
  
  /**
   * Ensures that all pending data is sent out to the target stream. This
   * implementation flushes the target stream.
   *
   * - throws IOException
   *             if an error occurs attempting to flush this stream.
   */
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  public override func flush() throws {
    try out.flush();
  }
  
  /**
   * Writes the entire contents of the byte array `buffer` to this
   * stream. This implementation writes the `buffer` to the target
   * stream.
   *
   * - Parameter buffer
   *            the buffer to be written.
   * - throws IOException
   *             if an I/O error occurs while writing to this stream.
   */
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  public override func write(_ buffer : [UInt8]) throws {
    try write(buffer, 0, buffer.length);
  }
  
  /**
   * Writes {@code count} bytes from the byte array `buffer` starting at
   * `offset` to the target stream.
   *
   * - Parameter buffer
   *            the buffer to write.
   * - Parameter offset
   *            the index of the first byte in {@code buffer} to write.
   * - Parameter length
   *            the number of bytes in {@code buffer} to write.
   * - throws ArrayIndexOutOfBoundsException
   *             if `offset < 0` or `count < 0`, or if
   *             `offset + count` is bigger than the length of
   *             buffer`.
   * - throws IOException
   *             if an I/O error occurs while writing to this stream.
   */
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  public override func write(_ buffer : [UInt8], _ offset : Int, _ length : Int) throws {
    // Force null buffer check first!
    if (offset > buffer.length || offset < 0) {
      throw java.lang.Throwable.ArrayIndexOutOfBoundsException(offset, "Offset out of bounds : \(offset)")
    }
    if (length < 0 || length > buffer.length - offset) {
      // luni.18=Length out of bounds \: {0}
      throw java.lang.Throwable.ArrayIndexOutOfBoundsException(length, "Length out of bounds : \(length)")
    }
    for i in 0..<length {
      // Call write() instead of out.write() since subclasses could
      // override the write() method.
      try write(Int(buffer[offset + i]))
    }
  }
  
  /**
   * Writes one byte to the target stream. Only the UInt8 value of the
   * integer `oneByte` is written.
   *
   * - Parameter oneByte
   *            the byte to be written.
   * - throws IOException
   *             if an I/O error occurs while writing to this stream.
   */
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  public override func write(_ oneByte : Int) throws {
    try out.write(oneByte)
  }
}
