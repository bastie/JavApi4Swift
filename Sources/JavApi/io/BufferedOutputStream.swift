/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * Wraps an existing ``java.io.OutputStream`` and `buffers` the output.
 *
 * Expensive interaction with the underlying input stream is minimized, since
 * most (smaller) requests can be satisfied by accessing the buffer alone. The
 * drawback is that some extra space is required to hold the buffer and that
 * copying takes place when flushing that buffer, but this is usually outweighed
 * by the performance benefits.
 *
 * A typical application pattern for the class looks like this:
 *
 * ```Swift
 * let buf = java.io.BufferedOutputStream(java.io.FileOutputStream("file.swift"));
 * ```
 *
 * see ``java.io.BufferedInputStream``
 */
extension java.io {
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  open class BufferedOutputStream : FilterOutputStream {
    /**
     * The buffer containing the bytes to be written to the target stream.
     */
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public var buf : [UInt8]
    
    /**
     * The total number of bytes inside the byte array {@code buf}.
     */
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public var count : Int = 0
    private var isClosed: Bool = false
    
    /**
     * Constructs a new {@code BufferedOutputStream} on the {@link OutputStream}
     * {@code out}. The buffer size is set to the default value of 8 KB.
     *
     * @param out
     *            the {@code OutputStream} for which write operations are
     *            buffered.
     */
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public override init(_ out : java.io.OutputStream) {
      buf = Array(Array(repeating: 0, count: 8192))
      super.init(out)
    }
    
    /**
     * Constructs a new {@code BufferedOutputStream} on the {@link OutputStream}
     * {@code out}. The buffer size is set to {@code size}.
     *
     * @param out
     *            the output stream for which write operations are buffered.
     * @param size
     *            the size of the buffer in bytes.
     * @throws IllegalArgumentException
     *             if {@code size <= 0}.
     */
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public init(_ out : java.io.OutputStream, _ size : Int) throws (IllegalArgumentException) {
      if (size <= 0) {
        throw IllegalArgumentException("size must be > 0")
      }
      buf = Array(repeating: 0, count: size)
      super.init(out);
    }
    
    /**
     * Flushes this stream to ensure all pending data is written out to the
     * target stream. In addition, the target stream is flushed.
     *
     * @throws IOException
     *             if an error occurs attempting to flush this stream.
     */
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public override func flush() throws {
      try flushInternal();
      try out.flush();
    }
    
    /**
     * Writes {@code count} bytes from the byte array {@code buffer} starting at
     * {@code offset} to this stream. If there is room in the buffer to hold the
     * bytes, they are copied in. If not, the buffered bytes plus the bytes in
     * {@code buffer} are written to the target stream, the target is flushed,
     * and the buffer is cleared.
     *
     * @param buffer
     *            the buffer to be written.
     * @param offset
     *            the start position in {@code buffer} from where to get bytes.
     * @param length
     *            the number of bytes from {@code buffer} to write to this
     *            stream.
     * @throws IndexOutOfBoundsException
     *             if {@code offset < 0} or {@code length < 0}, or if
     *             {@code offset + length} is greater than the size of
     *             {@code buffer}.
     * @throws IOException
     *             if an error occurs attempting to write to this stream.
     * @throws NullPointerException
     *             if {@code buffer} is {@code null}.
     * @throws ArrayIndexOutOfBoundsException
     *             If offset or count is outside of bounds.
     */
    public override func write(_ buffer : [UInt8], _ offset : Int, _ length : Int) throws {
      guard !isClosed else { throw java.io.IOException("Stream is closed") }
      if (length >= buf.count) {
        try flushInternal()
        try out.write(buffer, offset, length)
        return
      }

      if (offset < 0 || offset > buffer.count - length) {
        throw ArrayIndexOutOfBoundsException("Offset out of bounds : \(offset)")
      }
      if (length < 0) {
        throw ArrayIndexOutOfBoundsException("Length out of bounds : \(length)")
      }

      // flush the internal buffer first if we have not enough space left
      if (length >= (buf.count - count)) {
        try flushInternal()
      }

      // the length is always less than (buf.count - count) here so arraycopy is safe
      System.arraycopy(buffer, offset, &buf, count, length)
      count += length
    }
    
    public override func close() throws {
      guard !isClosed else { return }
      isClosed = true
      try flush()
      try super.close()
    }
    
    /**
     * Writes one byte to this stream. Only the low order byte of the integer
     * {@code oneByte} is written. If there is room in the buffer, the byte is
     * copied into the buffer and the count incremented. Otherwise, the buffer
     * plus {@code oneByte} are written to the target stream, the target is
     * flushed, and the buffer is reset.
     *
     * @param oneByte
     *            the byte to be written.
     * @throws IOException
     *             if an error occurs attempting to write to this stream.
     */
    public override func write(_ oneByte : Int) throws {
      guard !isClosed else { throw java.io.IOException("Stream is closed") }
      if (count == buf.count) {
        try out.write(buf, 0, count)
        count = 0
      }
      buf[count] = UInt8(oneByte)
      count += 1
      // Auto-flush when buffer is full after write
      if count == buf.count {
        try out.write(buf, 0, count)
        count = 0
      }
    }
    
    /**
     * Flushes only internal buffer.
     */
    private func flushInternal() throws {
      if (count > 0) {
        try out.write(buf, 0, count);
        count = 0;
      }
    }
  }
}
