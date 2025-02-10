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
import Synchronization

extension java.io {
  
  /**
   * The base class for all readers. A reader is a means of reading data from a
   * source in a character-wise manner. Some readers also support marking a
   * position in the input and returning to this position later.
   * <p>
   * This abstract class does not provide a fully working implementation, so it
   * needs to be subclassed, and at least the {@link #read(char[], int, int)} and
   * {@link #close()} methods needs to be overridden. Overriding some of the
   * non-abstract methods is also often advised, since it might result in higher
   * efficiency.
   * <p>
   * Many specialized readers for purposes like reading from a file already exist
   * in this package.
   *
   * @see Writer
   */
  open class Reader : @unchecked Sendable /*: Readable*/ ,Closeable {
    public typealias Closeable = Reader
    
    
    /**
     * The object used to synchronize access to the reader.
     */
    public let lock : Mutex<Sendable>
    
    /**
     * Constructs a new {@code Reader} with {@code this} as the object used to
     * synchronize critical sections.
     */
    public init() {
      lock = Mutex(Int(479117))
    }
    
    /**
     * Constructs a new {@code Reader} with {@code lock} used to synchronize
     * critical sections.
     *
     * @param lock
     *            the {@code Object} used to synchronize critical sections.
     */
    public init(_ lockObject : Sendable) {
      self.lock = Mutex(lockObject)
    }
    
    /**
     * Closes this reader. Implementations of this method should free any
     * resources associated with the reader.
     *
     * @throws IOException
     *             if an error occurs while closing this reader.
     */
    public func close() throws {
      throw java.io.Throwable.IOException("abstract function not yet implemented")
    };
    
    /**
     * Sets a mark position in this reader. The parameter {@code readLimit}
     * indicates how many characters can be read before the mark is invalidated.
     * Calling {@code reset()} will reposition the reader back to the marked
     * position if {@code readLimit} has not been surpassed.
     * <p>
     * This default implementation simply throws an {@code IOException};
     * subclasses must provide their own implementation.
     *
     * @param readLimit
     *            the number of characters that can be read before the mark is
     *            invalidated.
     * @throws IllegalArgumentException
     *             if {@code readLimit < 0}.
     * @throws IOException
     *             if an error occurs while setting a mark in this reader.
     * @see #markSupported()
     * @see #reset()
     */
    public func mark(_ readLimit : Int) throws {
      throw java.io.Throwable.IOException();
    }
    
    /**
     * Indicates whether this reader supports the {@code mark()} and
     * {@code reset()} methods. This default implementation returns
     * {@code false}.
     *
     * @return always {@code false}.
     */
    public func markSupported() -> Bool {
      return false;
    }
    
    /**
     * Reads a single character from this reader and returns it as an integer
     * with the two higher-order bytes set to 0. Returns -1 if the end of the
     * reader has been reached.
     *
     * @return the character read or -1 if the end of the reader has been
     *         reached.
     * @throws IOException
     *             if this reader is closed or some other I/O error occurs.
     */
    public func read() throws -> Int {
      try lock.withLock {_ in
        let charArray : [Character] = [Character](repeating: "\0", count: 1)
        if (try read(charArray, 0, 1) != -1) {
          return Int(charArray[0].unicodeScalars.first!.value)
        }
        return -1;
      }
    }
    
    /**
     * Reads characters from this reader and stores them in the character array
     * {@code buf} starting at offset 0. Returns the number of characters
     * actually read or -1 if the end of the reader has been reached.
     *
     * @param buf
     *            character array to store the characters read.
     * @return the number of characters read or -1 if the end of the reader has
     *         been reached.
     * @throws IOException
     *             if this reader is closed or some other I/O error occurs.
     */
    public func read(_ buf : [Character]) throws -> Int {
      return try read(buf, 0, buf.count)
    }
    
    /**
     * Reads at most {@code count} characters from this reader and stores them
     * at {@code offset} in the character array {@code buf}. Returns the number
     * of characters actually read or -1 if the end of the reader has been
     * reached.
     *
     * @param buf
     *            the character array to store the characters read.
     * @param offset
     *            the initial position in {@code buffer} to store the characters
     *            read from this reader.
     * @param count
     *            the maximum number of characters to read.
     * @return the number of characters read or -1 if the end of the reader has
     *         been reached.
     * @throws IOException
     *             if this reader is closed or some other I/O error occurs.
     */
    public func read(_ buf : [Character], _ offset : Int, _ count : Int)
    throws -> Int {
      throw java.io.Throwable.IOException("abstract method not yet implemented")
    }
    
    /**
     * Indicates whether this reader is ready to be read without blocking.
     * Returns {@code true} if this reader will not block when {@code read} is
     * called, {@code false} if unknown or blocking will occur. This default
     * implementation always returns {@code false}.
     *
     * @return always {@code false}.
     * @throws IOException
     *             if this reader is closed or some other I/O error occurs.
     * @see #read()
     * @see #read(char[])
     * @see #read(char[], int, int)
     */
    public func ready() throws -> Bool {
      return false;
    }
    
    /**
     * Resets this reader's position to the last {@code mark()} location.
     * Invocations of {@code read()} and {@code skip()} will occur from this new
     * location. If this reader has not been marked, the behavior of
     * {@code reset()} is implementation specific. This default
     * implementation throws an {@code IOException}.
     *
     * @throws IOException
     *             always thrown in this default implementation.
     * @see #mark(int)
     * @see #markSupported()
     */
    public func reset() throws {
      throw java.io.Throwable.IOException();
    }
    
    /**
     * Skips {@code amount} characters in this reader. Subsequent calls of
     * {@code read} methods will not return these characters unless {@code
     * reset()} is used. This method may perform multiple reads to read {@code
     * count} characters.
     *
     * @param count
     *            the maximum number of characters to skip.
     * @return the number of characters actually skipped.
     * @throws IllegalArgumentException
     *             if {@code amount < 0}.
     * @throws IOException
     *             if this reader is closed or some other I/O error occurs.
     * @see #mark(int)
     * @see #markSupported()
     * @see #reset()
     */
    public func skip(_ count : Int64) throws -> Int64 {
      if (count < 0) {
        throw java.lang.Throwable.IllegalArgumentException()
      }
      let skipped =
      try self.lock.withLock{_ in
        var _skipped : Int64 = 0
        var toRead : Int = count < 512 ? Int(count) : 512
        let charsSkipped : [Character] = Array(repeating: "\u{0}", count: toRead)
        while (_skipped < count) {
          let read = try read(charsSkipped, 0, toRead)
          if (read == -1) {
            return _skipped
          }
          _skipped += Int64(read)
          if (read < toRead) {
            return _skipped
          }
          if (count - _skipped < toRead) {
            toRead = Int (count - _skipped)
          }
        }
        return _skipped
      }
      return skipped
    }
    
    /**
     * Reads characters and puts them into the {@code target} character buffer.
     *
     * @param target
     *            the destination character buffer.
     * @return the number of characters put into {@code target} or -1 if the end
     *         of this reader has been reached before a character has been read.
     * @throws IOException
     *             if any I/O error occurs while reading from this reader.
     * @throws ReadOnlyBufferException
     *             if {@code target} is read-only.
     */
    public func read(_ target : java.nio.CharBuffer) throws -> Int {
      var length = target.length();
      let buf : [Character] = Array(repeating: "\u{0}", count: length)
      length = Math.min(length, try read(buf))
      if (length > 0) {
        _ = try target.put(buf, 0, length)
      }
      return length
    }
  }
}
