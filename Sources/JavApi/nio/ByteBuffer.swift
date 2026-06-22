/*
 * SPDX-FileCopyrightText: 2023, 2024, 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.nio {

  public typealias ByteBuffer = JavApi.ByteBuffer

}

/// A byte buffer with Java-compatible position/limit/capacity semantics.
///
/// The buffer maintains three state values that follow the Java invariant:
/// `0 <= position <= limit <= capacity`
///
/// - `capacity` – total number of bytes the buffer can hold (fixed at creation)
/// - `limit`    – index of the first byte that must not be read or written
/// - `position` – index of the next byte to be read or written
///
/// **Typical write → read cycle:**
/// ```swift
/// let buf = try ByteBuffer.allocate(4)
/// _ = try buf.put(UInt8(0xAA))
/// _ = try buf.put(UInt8(0xBB))
/// _ = buf.flip()          // limit = 2, position = 0
/// let a = try buf.get()   // 0xAA
/// let b = try buf.get()   // 0xBB
/// ```
open class ByteBuffer {

  // MARK: - State

  private var SELF_BYTE_ORDER: java.nio.ByteOrder = .BIG_ENDIAN

  /// The backing store. Always holds exactly `_capacity` elements.
  internal var content: [UInt8] = []

  private var _capacity: Int = 0
  private var _limit: Int = 0
  private var _position: Int = 0

  // MARK: - Initialisers (internal – use factory methods)

  public init() {}

  // MARK: - Factory methods

  /// Allocates a new byte buffer with the given capacity.
  ///
  /// The new buffer's position is 0, its limit equals its capacity, and
  /// every byte is initialised to zero — identical to Java.
  ///
  /// - Parameter count: The capacity of the new buffer; must be non-negative.
  /// - Throws: `IllegalArgumentException` if `count` is negative.
  /// - Since: Java 1.4
  public static func allocate(_ count: Int) throws -> ByteBuffer {
    guard count >= 0 else {
      throw IllegalArgumentException("Cannot allocate a ByteBuffer with negative capacity \(count)")
    }
    let buffer = ByteBuffer()
    buffer.content = Array(repeating: 0, count: count)
    buffer._capacity = count
    buffer._limit = count
    buffer._position = 0
    return buffer
  }

  /// Wraps a byte array into a buffer.
  ///
  /// The new buffer's capacity equals `array.count`, its position is 0
  /// and its limit equals its capacity — identical to Java.
  ///
  /// - Parameter array: The array to wrap.
  /// - Since: Java 1.4
  public static func wrap(_ array: [UInt8]) -> ByteBuffer {
    return wrap(array, 0, array.count)
  }

  /// Wraps a byte array into a buffer using a sub-range as the initial
  /// position/limit window.
  ///
  /// The new buffer's capacity equals `array.count`, its position is
  /// `offset` and its limit is `offset + length` — identical to Java.
  ///
  /// - Parameters:
  ///   - array:  The array to wrap.
  ///   - offset: Initial position; 0 ≤ offset ≤ array.count.
  ///   - length: Number of elements for the initial window; 0 ≤ length ≤ array.count − offset.
  /// - Since: Java 1.4
  public static func wrap(_ array: [UInt8], _ offset: Int, _ length: Int) -> ByteBuffer {
    let buffer = ByteBuffer()
    buffer.content = array
    buffer._capacity = array.count
    buffer._position = offset
    buffer._limit = offset + length
    return buffer
  }

  // MARK: - Capacity / limit / position / remaining

  /// Returns this buffer's capacity.
  /// - Since: Java 1.4
  open func capacity() -> Int { _capacity }

  /// Returns this buffer's limit.
  /// - Since: Java 1.4
  open func limit() -> Int { _limit }

  /// Sets this buffer's limit.
  ///
  /// If the position is greater than the new limit, the position is set
  /// to the new limit — identical to Java.
  ///
  /// - Parameter newLimit: The new limit; must be 0 ≤ newLimit ≤ capacity.
  /// - Throws: `IllegalArgumentException` if `newLimit` is out of range.
  /// - Since: Java 1.4
  @discardableResult
  open func limit(_ newLimit: Int) throws -> ByteBuffer {
    guard newLimit >= 0 && newLimit <= _capacity else {
      throw IllegalArgumentException("limit \(newLimit) out of range for capacity \(_capacity)")
    }
    _limit = newLimit
    if _position > _limit { _position = _limit }
    return self
  }

  /// Returns this buffer's position.
  /// - Since: Java 1.4
  open func position() -> Int { _position }

  /// Sets this buffer's position.
  ///
  /// - Parameter newPosition: The new position; must be 0 ≤ newPosition ≤ limit.
  /// - Throws: `IllegalArgumentException` if `newPosition` is out of range.
  /// - Since: Java 1.4
  @discardableResult
  open func position(_ newPosition: Int) throws -> ByteBuffer {
    guard newPosition >= 0 && newPosition <= _limit else {
      throw IllegalArgumentException("position \(newPosition) out of range for limit \(_limit)")
    }
    _position = newPosition
    return self
  }

  /// Returns the number of elements between the current position and the limit.
  /// - Since: Java 1.4
  open func remaining() -> Int { _limit - _position }

  /// Returns `true` if there is at least one element between the position and the limit.
  /// - Since: Java 1.4
  open func hasRemaining() -> Bool { _position < _limit }

  // MARK: - Flip / clear / rewind

  /// Flips this buffer: limit ← position, position ← 0.
  ///
  /// After a sequence of `put` operations, `flip` prepares the buffer
  /// for a subsequent sequence of `get` operations — identical to Java.
  ///
  /// - Since: Java 1.4
  @discardableResult
  open func flip() -> ByteBuffer {
    _limit = _position
    _position = 0
    return self
  }

  /// Clears this buffer: position ← 0, limit ← capacity.
  ///
  /// The data is not erased. Prepares the buffer for a fresh write cycle.
  ///
  /// - Since: Java 1.4
  @discardableResult
  open func clear() -> ByteBuffer {
    _position = 0
    _limit = _capacity
    return self
  }

  /// Rewinds this buffer: position ← 0 (limit unchanged).
  ///
  /// Allows re-reading data that was already read.
  ///
  /// - Since: Java 1.4
  @discardableResult
  open func rewind() -> ByteBuffer {
    _position = 0
    return self
  }

  // MARK: - Byte order

  /// Returns the byte order of this buffer. Default is `BIG_ENDIAN`.
  ///
  /// The byte order governs how multi-byte primitives (`getInt`, `putInt`, …)
  /// are interpreted. It does **not** affect the backing array layout.
  ///
  /// - Since: Java 1.4
  open func order() -> java.nio.ByteOrder { SELF_BYTE_ORDER }

  /// Sets the byte order of this buffer and returns `self` for chaining.
  ///
  /// - Since: Java 1.4
  @discardableResult
  open func order(_ order: java.nio.ByteOrder) -> ByteBuffer {
    SELF_BYTE_ORDER = order
    return self
  }

  // MARK: - Array access

  /// Returns the backing byte array.
  ///
  /// The returned array contains all `capacity` bytes regardless of position
  /// or limit — identical to Java.
  ///
  /// - Since: Java 1.4
  open func array() throws -> [UInt8] { content }

  // MARK: - Relative put

  /// Writes `byte` at the current position and increments the position.
  ///
  /// - Throws: `java.nio.BufferOverflowException` if `position >= limit`.
  /// - Since: Java 1.4
  @discardableResult
  open func put(_ byte: UInt8) throws -> ByteBuffer {
    guard _position < _limit else {
      throw java.nio.BufferOverflowException("Buffer is full (position=\(_position), limit=\(_limit))")
    }
    content[_position] = byte
    _position += 1
    return self
  }

  /// Writes all bytes from `bytes` into this buffer starting at the current position.
  ///
  /// - Throws: `java.nio.BufferOverflowException` if `remaining() < bytes.count`.
  /// - Since: Java 1.4
  @discardableResult
  open func put(_ bytes: [UInt8]) throws -> ByteBuffer {
    for byte in bytes {
      try _ = self.put(byte)
    }
    return self
  }

  /// Writes `length` bytes from `bytes` starting at `offset` into this buffer
  /// at the current position.
  ///
  /// - Parameters:
  ///   - bytes:  Source array.
  ///   - offset: Start index in `bytes`; must be 0 ≤ offset ≤ bytes.count.
  ///   - length: Number of bytes to copy; must be 0 ≤ length ≤ bytes.count − offset.
  /// - Throws: `IndexOutOfBoundsException` if offset/length are out of range for `bytes`.
  /// - Throws: `java.nio.BufferOverflowException` if `remaining() < length`.
  /// - Since: Java 1.4
  @discardableResult
  open func put(_ bytes: [UInt8], _ offset: Int, _ length: Int) throws -> ByteBuffer {
    guard offset >= 0 && length >= 0 && (offset + length) <= bytes.count else {
      throw IndexOutOfBoundsException("illegal offset \(offset) or length \(length) for array of size \(bytes.count)")
    }
    for i in offset..<(offset + length) {
      try _ = self.put(bytes[i])
    }
    return self
  }

  // MARK: - Relative / absolute get

  /// Reads the byte at the current position and increments the position.
  ///
  /// - Throws: `java.nio.BufferUnderflowException` if `position >= limit`.
  /// - Since: Java 1.4
  open func get() throws -> UInt8 {
    guard _position < _limit else {
      throw java.nio.BufferUnderflowException("Buffer is empty (position=\(_position), limit=\(_limit))")
    }
    let byte = content[_position]
    _position += 1
    return byte
  }

  /// Reads the byte at the given absolute `index` without changing the position.
  ///
  /// - Parameter index: The index to read; must be 0 ≤ index < limit.
  /// - Throws: `IndexOutOfBoundsException` if `index` is out of range.
  /// - Since: Java 1.4
  open func get(_ index: Int) throws -> UInt8 {
    guard index >= 0 && index < _limit else {
      throw IndexOutOfBoundsException("index \(index) out of bounds for limit \(_limit)")
    }
    return content[index]
  }
}
