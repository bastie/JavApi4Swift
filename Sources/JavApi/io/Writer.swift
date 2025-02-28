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

import Foundation

extension java.io {
  
  /**
   * The base class for all writers. A writer is a means of writing data to a
   * target in a character-wise manner. Most output streams expect the
   * {@link #flush()} method to be called before closing the stream, to ensure all
   * data is actually written out.
   * <p>
   * This abstract class does not provide a fully working implementation, so it
   * needs to be subclassed, and at least the {@link #write(char[], int, int)},
   * {@link #close()} and {@link #flush()} methods needs to be overridden.
   * Overriding some of the non-abstract methods is also often advised, since it
   * might result in higher efficiency.
   * <p>
   * Many specialized readers for purposes like reading from a file already exist
   * in this package.
   *
   * @see Reader
   */
  open class Writer : Appendable, java.io.Closeable, java.io.Flushable {
    public typealias Closeable = Writer
    
    public typealias Flushable = Writer
    
    
    open func append(_ c: Character) throws -> any Appendable {
      try self.write([c])
      return self
    }
    
    open func append(_ csq: any CharSequence) throws -> any Appendable {
      try self.write(csq.toString().toCharArray())
      return self
    }
    
    open func append(_ csq: any CharSequence, _ start: Int, _ end: Int) throws -> any Appendable {
      try self.write(csq.toString().substring(start, end).toCharArray())
      return self
    }


    internal let TOKEN_NULL = "null"
    
    /**
     * The object used to synchronize access to the writer.
     */
    public var lock : NSLock?
    
    /**
     * Constructs a new {@code Writer} with {@code this} as the object used to
     * synchronize critical sections.
     */
    public init() {
      lock = NSLock()
    }
    
    /**
     * Constructs a new {@code Writer} with {@code lock} used to synchronize
     * critical sections.
     *
     * @param lock
     *            the {@code Object} used to synchronize critical sections.
     * @throws NullPointerException
     *             if {@code lock} is {@code null}.
     */
    public init(_ lock : NSLock?) throws {
      if let lock {
        self.lock = lock;
      }
      else {
        throw java.lang.Throwable.NullPointerException()
      }
    }
    
    /**
     * Closes this writer. Implementations of this method should free any
     * resources associated with the writer.
     *
     * @throws IOException
     *             if an error occurs while closing this writer.
     */
    open func close() throws {
      throw java.lang.Throwable.AbstractMethodError("java.io.Writer.close")
    }
    
    /**
     * Flushes this writer. Implementations of this method should ensure that
     * all buffered characters are written to the target.
     *
     * @throws IOException
     *             if an error occurs while flushing this writer.
     */
    open func flush() throws {
      throw java.lang.Throwable.AbstractMethodError("java.io.Writer.flush")
    }
    
    /**
     * Writes the entire character buffer {@code buf} to the target.
     *
     * @param buf
     *            the non-null array containing characters to write.
     * @throws IOException
     *             if this writer is closed or another I/O error occurs.
     */
    open func write(_ buf : [Character]) throws {
      try write(buf, 0, buf.length);
    }
    
    /**
     * Writes {@code count} characters starting at {@code offset} in {@code buf}
     * to the target.
     *
     * @param buf
     *            the non-null character array to write.
     * @param offset
     *            the index of the first character in {@code buf} to write.
     * @param count
     *            the maximum number of characters to write.
     * @throws IndexOutOfBoundsException
     *             if {@code offset < 0} or {@code count < 0}, or if {@code
     *             offset + count} is greater than the size of {@code buf}.
     * @throws IOException
     *             if this writer is closed or another I/O error occurs.
     */
    open func write(_ buf : [Character], _ offset : Int, _ count : Int) throws {
      throw java.lang.Throwable.AbstractMethodError("java.io.Writer.write([Character],Int,Int")
    }
    
    /**
     * Writes one character to the target. Only the two least significant bytes
     * of the integer {@code oneChar} are written.
     *
     * @param oneChar
     *            the character to write to the target.
     * @throws IOException
     *             if this writer is closed or another I/O error occurs.
     */
    open func write(_ oneChar : Character) throws {
      lock?.lock()
      let oneCharArray : [Character] = Array.init(repeating: oneChar, count: 1)
      //oneCharArray[0] = (char) oneChar;
      try write(oneCharArray);
      lock?.unlock()
    }
    
    /**
     * Writes the characters from the specified string to the target.
     *
     * @param str
     *            the non-null string containing the characters to write.
     * @throws IOException
     *             if this writer is closed or another I/O error occurs.
     */
    open func write(_ str : String) throws {
      try write(str, 0, str.count)
    }
    
    /**
     * Writes {@code count} characters from {@code str} starting at {@code
     * offset} to the target.
     *
     * @param str
     *            the non-null string containing the characters to write.
     * @param offset
     *            the index of the first character in {@code str} to write.
     * @param count
     *            the number of characters from {@code str} to write.
     * @throws IOException
     *             if this writer is closed or another I/O error occurs.
     * @throws IndexOutOfBoundsException
     *             if {@code offset < 0} or {@code count < 0}, or if {@code
     *             offset + count} is greater than the length of {@code str}.
     */
    open func write (_ str : String, _ offset : Int, _ count : Int) throws {
      if (count < 0) { // other cases tested by getChars()
        throw java.lang.Throwable.StringIndexOutOfBoundsException(-1)
      }
      var buf : [Character] = Array.init(repeating: "\u{0}", count: count)
      str.getChars(offset, offset + count, &buf, 0)
      
      lock?.lock()
      try write(buf, 0, buf.count);
      lock?.unlock()
    }
    
    /**
     * Appends the character {@code c} to the target. This method works the same
     * way as {@link #write(int)}.
     *
     * @param c
     *            the character to append to the target stream.
     * @return this writer.
     * @throws IOException
     *             if this writer is closed or another I/O error occurs.
     */
    open func append(_ c : Character) throws -> Writer {
      try write(c);
      return self;
    }
    
    /**
     * Appends the character sequence {@code csq} to the target. This method
     * works the same way as {@code Writer.write(csq.toString())}. If {@code
     * csq} is {@code null}, then the string "null" is written to the target
     * stream.
     *
     * @param csq
     *            the character sequence appended to the target.
     * @return this writer.
     * @throws IOException
     *             if this writer is closed or another I/O error occurs.
     */
    open func append(_ csq : (any CharSequence)?) throws -> Writer {
      if (nil == csq) {
        try write(TOKEN_NULL);
      } else {
        try write(csq!.toString());
      }
      return self;
    }
    
    /**
     * Appends a subsequence of the character sequence {@code csq} to the
     * target. This method works the same way as {@code
     * Writer.writer(csq.subsequence(start, end).toString())}. If {@code
     * csq} is {@code null}, then the specified subsequence of the string "null"
     * will be written to the target.
     *
     * @param csq
     *            the character sequence appended to the target.
     * @param start
     *            the index of the first char in the character sequence appended
     *            to the target.
     * @param end
     *            the index of the character following the last character of the
     *            subsequence appended to the target.
     * @return this writer.
     * @throws IOException
     *             if this writer is closed or another I/O error occurs.
     * @throws IndexOutOfBoundsException
     *             if {@code start > end}, {@code start < 0}, {@code end < 0} or
     *             either {@code start} or {@code end} are greater or equal than
     *             the length of {@code csq}.
     */
    open func append(_ csq : (any CharSequence)?, _ start : Int, _ end : Int) throws -> Writer {
      if (nil == csq) {
        try write(TOKEN_NULL.substring(start, end))
      } else {
        try write("\(csq!)".substring(start, end))
      }
      return self;
    }
    
    /**
     * Returns true if this writer has encountered and suppressed an error. Used
     * by PrintWriters as an alternative to checked exceptions.
     */
    internal func checkError() -> Bool{
      return false
    }
  }
}
