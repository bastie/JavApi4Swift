/*
 * SPDX-FileCopyrightText: 2023-2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// final class => public

/// A mutable string, `java.lang.StringBuilder` equivalent.
///
/// **Deliberately not `Sendable`**: this mirrors Java, where `StringBuilder`
/// is explicitly documented as *not* thread-safe (unsynchronised, for
/// performance) — unlike `StringBuffer`, which is. `content` has no lock and
/// must not be shared across concurrent tasks/threads without external
/// synchronisation; use ``StringBuffer`` instead if that is required.
public class StringBuilder {

  var content : String = "" // TODO: implements direct a char array
  
  /// Default constructor
  public init (){}
  
  public init (_ newContent : String) {
    self.content = newContent
  }
  
  // TODO: Test it
  public init<CS: JavApi.CharSequence> (_ newContent : CS) {
    self.content = newContent.toString()
  }
  
  /// Append a String type
  /// - Parameters String to append
  /// - Returns self (fluent interface pattern)
  public func append (_ s : String) -> StringBuilder{
    self.content.append(s)
    return self
  }
  public func append (_ s: String, _ start: Int, _ end: Int) -> StringBuilder {
    self.content.append(s.substring(start, end))
    return self
  }

  public func append (_ c : Character) -> StringBuilder{
    self.content.append(c)
    return self
  }
  public func append (_ cs : [Character]) -> StringBuilder{
    for c in cs { // FIXME: better implementation needed
      self.content.append(c)
    }
    return self
  }
  
  public func charAt (_ offset : Int) throws -> Character {
    guard offset > -1, offset < self.count else {
      throw IndexOutOfBoundsException("the index \(offset) is negative or greater than or equal to count of String")
    }
    return Array (self.content)[offset]
  }
  
  /// Removes the `Character` at the specified position in this sequence,
  /// matching `java.lang.StringBuilder.deleteCharAt(int)`: the receiver is
  /// mutated in place and returned (fluent interface pattern), analogous to
  /// `append`/`setLength`.
  @discardableResult
  public func deleteCharAt (_ offset : Int) throws -> StringBuilder {
    guard offset > -1, offset < self.count else {
      throw IndexOutOfBoundsException("the index \(offset) is negative or greater than or equal to count of String")
    }
    var asCharArray = Array(self.content)
    // Bugfix: `removeFirst(offset)` removes the first `offset` elements
    // instead of the single element AT index `offset` - use `remove(at:)`.
    asCharArray.remove(at: offset)
    self.content = String(asCharArray)
    return self
  }
  
  public func length () -> Int {
    return content.length()
  }
  
  /// Truncates or pads (with null characters) this builder to the given
  /// length.
  ///
  /// Bugfix: the previous implementation only ever grew `content` (via
  /// the padding loop) and had a dead `if newLength < self.content.count`
  /// branch with no actual truncation code in it, so shrinking via
  /// `setLength(shorter)` silently did nothing instead of truncating —
  /// unlike ``StringBuffer/setLength(_:)``, which already truncates
  /// correctly.
  ///
  /// Mirrors `java.lang.StringBuilder.setLength(int)`.
  public func setLength (_ newLength : Int) throws {
    guard newLength >= 0 else {
      throw IndexOutOfBoundsException("New length need to be equals or greater than zero but is \(newLength)")
    }
    if newLength == 0 {
      self.content = ""
    } else if newLength < self.content.count {
      self.content = String(self.content.prefix(newLength))
    } else {
      while self.content.count < newLength {
        self.content.append("\u{0000}")
      }
    }
  }

  /// Returns the current capacity.
  ///
  /// Advisory only: Swift `String` grows automatically, so this reports
  /// the builder's current length as a lower bound rather than a true
  /// pre-allocated capacity.
  ///
  /// Mirrors `java.lang.StringBuilder.capacity()`.
  /// - Since: JavaApi (Java 1.0)
  public func capacity() -> Int {
    return content.count
  }

  /// Ensures this builder's capacity is at least `minimumCapacity`.
  ///
  /// Advisory only — hints the underlying storage via
  /// `reserveCapacity(_:)`; Swift `String` still grows automatically
  /// beyond this if needed.
  ///
  /// Mirrors `java.lang.StringBuilder.ensureCapacity(int)`.
  /// - Since: JavaApi (Java 1.0)
  public func ensureCapacity(_ minimumCapacity: Int) {
    guard minimumCapacity > 0 else { return }
    content.reserveCapacity(minimumCapacity)
  }

  /// Attempts to reduce storage used for this builder.
  ///
  /// No-op in this Swift port — `String` manages its own storage and
  /// offers no equivalent "trim to size" operation.
  ///
  /// Mirrors `java.lang.StringBuilder.trimToSize()`.
  /// - Since: JavaApi (Java 1.0)
  public func trimToSize() {}
  
  public func toString () -> String {
    return self.content
  }
  
  
// FIXME: better implement StringProtocol
  public func substring (_ start : Int, _ end : Int) -> String {
    return self.content.subSequence(start,end)
  }
  
  public func substring (_ start: Int) -> String {
    return self.content.subSequence(start, self.count)
  }
}


