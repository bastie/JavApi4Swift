/*
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

extension java.io {
  /**
   * A specialized {@link Writer} for class for writing content to an (internal)
   * char array. As bytes are written to this writer, the char array may be
   * expanded to hold more characters. When the writing is considered to be
   * finished, a copy of the char array can be requested from the class.
   *
   * @see CharArrayReader
   */
  open class CharArrayWriter : java.io.Writer {
    
    /**
     * The buffer for characters.
     */
    public var buf : [Character]
    
    /**
     * The ending index of the buffer.
     */
    public var count : Int
    
    /**
     * Constructs a new {@code CharArrayWriter} which has a buffer allocated
     * with the default size of 32 characters. This buffer is also used as the
     * {@code lock} to synchronize access to this writer.
     */
    public override init() {
      self.buf = Array(repeating: "\u{0}", count: 32)
      self.count = 0
      super.init()
    }
    
    /**
     * Constructs a new {@code CharArrayWriter} which has a buffer allocated
     * with the size of {@code initialSize} characters. The buffer is also used
     * as the {@code lock} to synchronize access to this writer.
     *
     * @param initialSize
     *            the initial size of this CharArrayWriters buffer.
     * @throws IllegalArgumentException
     *             if {@code initialSize < 0}.
     */
    public init(_ initialSize : Int) throws {
      guard initialSize >= 0 else {
        throw java.lang.Throwable.IllegalArgumentException("array size must be non-negative")
      }
      buf = Array(repeating: "\u{0}", count: initialSize)
      self.count = 0
      super.init()
    }
    
    /**
     * Closes this writer. The implementation in {@code CharArrayWriter} does nothing.
     */
    public override func close() {
      /* empty */
    }
    
    private func expand(_ i : Int) {
      /* Can the buffer handle @i more chars, if not expand it */
      if (count + i <= buf.count) {
        return;
      }
      else {
        for _ in 0..<buf.count - i {
          buf.append("\u{0}")
        }
      }
    }
    
    /**
     * Flushes this writer. The implementation in {@code CharArrayWriter} does nothing.
     */
    open override func flush() {
      /* empty */
    }
    
    /**
     * Resets this writer. The current write position is reset to the beginning
     * of the buffer. All written characters are lost and the size of this
     * writer is set to 0.
     */
    open func reset() {
      self.lock?.lock()
      defer {
        self.lock?.unlock()
      }
      
      count = 0
    }
    
    /**
     * Returns the size of this writer, that is the number of characters it
     * stores. This number changes if this writer is reset or when more
     * characters are written to it.
     *
     * @return this CharArrayWriter's current size in characters.
     */
    open func size() -> Int {
      self.lock?.lock()
      defer {
        self.lock?.unlock()
      }
      
      return count
    }
    
    /**
     * Returns the contents of the receiver as a char array. The array returned
     * is a copy and any modifications made to this writer after calling this
     * method are not reflected in the result.
     *
     * @return this CharArrayWriter's contents as a new char array.
     */
    open func toCharArray() -> [Character]{
      self.lock?.lock()
      defer {
        self.lock?.unlock()
      }
      var newArray = Array(self.buf)
      newArray.removeLast(newArray.count-self.count)
      return newArray
    }
    
    /**
     * Returns the contents of this {@code CharArrayWriter} as a string. The
     * string returned is a copy and any modifications made to this writer after
     * calling this method are not reflected in the result.
     *
     * @return this CharArrayWriters contents as a new string.
     */
    open func toString() -> String{
      self.lock?.lock()
      defer {
        self.lock?.unlock()
      }
      
      return String(buf, 0, count)
    }
    
    /**
     * Writes {@code count} characters starting at {@code offset} in {@code c}
     * to this writer.
     *
     * @param c
     *            the non-null array containing characters to write.
     * @param offset
     *            the index of the first character in {@code buf} to write.
     * @param len
     *            maximum number of characters to write.
     * @throws IndexOutOfBoundsException
     *             if {@code offset < 0} or {@code len < 0}, or if
     *             {@code offset + len} is bigger than the size of {@code c}.
     */
    open override func write(_ c : [Character], _ offset : Int, _ len : Int) throws {
      // avoid int overflow
      if (offset < 0 || offset > c.count || len < 0
          || len > c.count - offset) {
        throw java.lang.Throwable.IndexOutOfBoundsException();
      }
      self.lock?.lock()
      defer {
        self.lock?.unlock()
      }
      
      let newElementsCount = len - offset
      for i in 0..<newElementsCount {
        self.buf[self.count + i] = c[offset + i]
      }
      self.count += newElementsCount
    }
    
    /**
     * Writes the specified character {@code oneChar} to this writer.
     * This implementation writes the two low order bytes of the integer
     * {@code oneChar} to the buffer.
     *
     * @param oneChar
     *            the character to write.
     */
    public override func write(_ oneChar : Character) {
      self.lock?.lock()
      defer {
        self.lock?.unlock()
      }
      
      if self.count < self.buf.count {
        self.buf.append(oneChar)
      }
      else {
        self.buf[self.count] = oneChar
      }
      self.count += 1
    }
    
    /**
     * Writes {@code count} number of characters starting at {@code offset} from
     * the string {@code str} to this CharArrayWriter.
     *
     * @param str
     *            the non-null string containing the characters to write.
     * @param offset
     *            the index of the first character in {@code str} to write.
     * @param len
     *            the number of characters to retrieve and write.
     * @throws StringIndexOutOfBoundsException
     *             if {@code offset < 0} or {@code len < 0}, or if
     *             {@code offset + len} is bigger than the length of
     *             {@code str}.
     */
    public override func write(_ str : String, _ offset : Int, _ len : Int) throws {
      try self.write(str.toCharArray(), offset, len)
    }
    
    /**
     * Writes the contents of this {@code CharArrayWriter} to another {@code
     * Writer}. The output is all the characters that have been written to the
     * receiver since the last reset or since it was created.
     *
     * @param out
     *            the non-null {@code Writer} on which to write the contents.
     * @throws IOException
     *             if an error occurs attempting to write out the contents.
     */
    public func writeTo(_ writer : java.io.Writer) throws {
      self.lock?.lock()
      defer {
        self.lock?.unlock()
      }
      try writer.write(buf, 0, count);
    }
    
    /**
     * Appends a char {@code c} to the {@code CharArrayWriter}. The method works
     * the same way as {@code write(c)}.
     *
     * @param c
     *            the character appended to the CharArrayWriter.
     * @return this CharArrayWriter.
     */
    public override func append(_ c : Character) throws -> CharArrayWriter {
      self.write(c)
      return self
    }
    
    /**
     * Appends a {@code CharSequence} to the {@code CharArrayWriter}. The method
     * works the same way as {@code write(csq.toString())}. If {@code csq} is
     * {@code null}, then it will be substituted with the string {@code "null"}.
     *
     * @param csq
     *            the {@code CharSequence} appended to the {@code
     *            CharArrayWriter}, may be {@code null}.
     * @return this CharArrayWriter.
     */
    public override func append(_ csq : (any CharSequence)?) throws -> CharArrayWriter {
      if (nil == csq) {
        _ = try append(TOKEN_NULL, 0, TOKEN_NULL.count)
      } else {
        _ = try append(csq!, 0, csq!.toString().count)
      }
      return self
    }
    
    /**
     * Append a subsequence of a {@code CharSequence} to the {@code
     * CharArrayWriter}. The first and last characters of the subsequence are
     * specified by the parameters {@code start} and {@code end}. A call to
     * {@code CharArrayWriter.append(csq)} works the same way as {@code
     * CharArrayWriter.write(csq.subSequence(start, end).toString)}. If {@code
     * csq} is {@code null}, then it will be substituted with the string {@code
     * "null"}.
     *
     * @param csq
     *            the {@code CharSequence} appended to the {@code
     *            CharArrayWriter}, may be {@code null}.
     * @param start
     *            the index of the first character in the {@code CharSequence}
     *            appended to the {@code CharArrayWriter}.
     * @param end
     *            the index of the character after the last one in the {@code
     *            CharSequence} appended to the {@code CharArrayWriter}.
     * @return this CharArrayWriter.
     * @throws IndexOutOfBoundsException
     *             if {@code start < 0}, {@code end < 0}, {@code start > end},
     *             or if {@code end} is greater than the length of {@code csq}.
     */
    public override func append(_ _csq : (any CharSequence)?, _ _start : Int, _ _end : Int) throws -> CharArrayWriter {
      var csq = _csq
      var start = _start
      var end = _end
      if (nil == csq) {
        csq = TOKEN_NULL
        start = 0
        end = TOKEN_NULL.count
      }
      let output = String(Array((csq!.toString().toCharArray()[start..<end])))
      try write(output, 0, output.count);
      return self
    }
  }
}
