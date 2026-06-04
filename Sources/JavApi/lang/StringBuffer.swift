/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

/// Thread-safe mutable string, Java 1.0 equivalent of `java.lang.StringBuffer`.
///
/// `StringBuffer` has the same API as ``StringBuilder`` but all mutating methods
/// are synchronised via an `NSLock`, matching Java's `synchronized` semantics.
///
/// For single-threaded use, prefer ``StringBuilder`` which has lower overhead.
public final class StringBuffer {

  private var content: String = ""
  private let lock = NSLock()

  // MARK: - Constructors

  /// Default constructor – creates an empty buffer
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public init() {}

  /// Creates a buffer containing the given String
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public init(_ newContent: String) {
    self.content = newContent
  }

  /// Creates a buffer containing the given CharSequence
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public init(_ newContent: any CharSequence) {
    self.content = "\(newContent)"
  }

  /// Creates a buffer from an existing StringBuilder
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public init(_ sb: StringBuilder) {
    self.content = sb.toString()
  }

  // MARK: - Append

  /// Append a String
  /// - Returns self (fluent interface pattern)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @discardableResult
  public func append(_ s: String) -> StringBuffer {
    lock.lock(); defer { lock.unlock() }
    content.append(s)
    return self
  }

  /// Append a substring range of the given String
  /// - Returns self (fluent interface pattern)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @discardableResult
  public func append(_ s: String, _ start: Int, _ end: Int) -> StringBuffer {
    lock.lock(); defer { lock.unlock() }
    content.append(s.substring(start, end))
    return self
  }

  /// Append a Character
  /// - Returns self (fluent interface pattern)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @discardableResult
  public func append(_ c: Character) -> StringBuffer {
    lock.lock(); defer { lock.unlock() }
    content.append(c)
    return self
  }

  /// Append a character array
  /// - Returns self (fluent interface pattern)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @discardableResult
  public func append(_ cs: [Character]) -> StringBuffer {
    lock.lock(); defer { lock.unlock() }
    for c in cs { content.append(c) }
    return self
  }

  // MARK: - Insert

  /// Insert a String at the given offset
  /// - Returns self (fluent interface pattern)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @discardableResult
  public func insert(_ offset: Int, _ s: String) throws -> StringBuffer {
    lock.lock(); defer { lock.unlock() }
    guard offset >= 0, offset <= content.count else {
      throw StringIndexOutOfBoundsException("index \(offset) is out of bounds for length \(content.count)")
    }
    let idx = content.index(content.startIndex, offsetBy: offset)
    content.insert(contentsOf: s, at: idx)
    return self
  }

  // MARK: - Delete

  /// Delete the character at the given index
  /// - Returns self (fluent interface pattern)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @discardableResult
  public func deleteCharAt(_ offset: Int) throws -> StringBuffer {
    lock.lock(); defer { lock.unlock() }
    guard offset >= 0, offset < content.count else {
      throw IndexOutOfBoundsException("the index \(offset) is negative or greater than or equal to count of String")
    }
    var chars = Array(content)
    chars.remove(at: offset)
    content = String(chars)
    return self
  }

  /// Delete characters in the range [start, end)
  /// - Returns self (fluent interface pattern)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @discardableResult
  public func delete(_ start: Int, _ end: Int) throws -> StringBuffer {
    lock.lock(); defer { lock.unlock() }
    guard start >= 0, start <= end, start <= content.count else {
      throw StringIndexOutOfBoundsException("range [\(start),\(end)) is invalid for length \(content.count)")
    }
    let clampedEnd = min(end, content.count)
    let startIdx = content.index(content.startIndex, offsetBy: start)
    let endIdx = content.index(content.startIndex, offsetBy: clampedEnd)
    content.removeSubrange(startIdx..<endIdx)
    return self
  }

  // MARK: - Replace

  /// Replace characters in range [start, end) with the given String
  /// - Returns self (fluent interface pattern)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @discardableResult
  public func replace(_ start: Int, _ end: Int, _ str: String) throws -> StringBuffer {
    lock.lock(); defer { lock.unlock() }
    guard start >= 0, start <= end, start <= content.count else {
      throw StringIndexOutOfBoundsException("range [\(start),\(end)) is invalid for length \(content.count)")
    }
    let clampedEnd = min(end, content.count)
    let startIdx = content.index(content.startIndex, offsetBy: start)
    let endIdx = content.index(content.startIndex, offsetBy: clampedEnd)
    content.replaceSubrange(startIdx..<endIdx, with: str)
    return self
  }

  // MARK: - Reverse

  /// Reverse the character sequence in place
  /// - Returns self (fluent interface pattern)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @discardableResult
  public func reverse() -> StringBuffer {
    lock.lock(); defer { lock.unlock() }
    content = String(content.reversed())
    return self
  }

  // MARK: - charAt / length / setLength

  /// Returns the character at the given index
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func charAt(_ offset: Int) throws -> Character {
    lock.lock(); defer { lock.unlock() }
    guard offset >= 0, offset < content.count else {
      throw IndexOutOfBoundsException("the index \(offset) is negative or greater than or equal to count of String")
    }
    return Array(content)[offset]
  }

  /// Returns the number of characters in the buffer
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func length() -> Int {
    lock.lock(); defer { lock.unlock() }
    return content.count
  }

  /// Truncates or pads (with null characters) the buffer to the given length
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func setLength(_ newLength: Int) throws {
    guard newLength >= 0 else {
      throw IndexOutOfBoundsException("New length must be >= 0 but is \(newLength)")
    }
    lock.lock(); defer { lock.unlock() }
    if newLength == 0 {
      content = ""
    } else if newLength < content.count {
      content = String(content.prefix(newLength))
    } else {
      while content.count < newLength {
        content.append("\u{0000}")
      }
    }
  }

  // MARK: - Substring

  /// Returns the substring starting at start up to the end
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func substring(_ start: Int) -> String {
    lock.lock(); defer { lock.unlock() }
    return content.subSequence(start, content.count)
  }

  /// Returns the substring in range [start, end)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func substring(_ start: Int, _ end: Int) -> String {
    lock.lock(); defer { lock.unlock() }
    return content.subSequence(start, end)
  }

  // MARK: - toString

  /// Returns the string representation of the buffer
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func toString() -> String {
    lock.lock(); defer { lock.unlock() }
    return content
  }
}
