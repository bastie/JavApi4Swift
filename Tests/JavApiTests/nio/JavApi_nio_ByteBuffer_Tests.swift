/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

// MARK: - ByteOrder Tests

struct JavApi_nio_ByteOrder_Tests {

  @Test("ByteOrder Konstanten sind definiert")
  func testConstants() {
    let big = java.nio.ByteOrder.BIG_ENDIAN
    let little = java.nio.ByteOrder.LITTLE_ENDIAN
    #expect(big.toString() == "BIG_ENDIAN")
    #expect(little.toString() == "LITTLE_ENDIAN")
  }

  @Test("ByteOrder Gleichheit")
  func testEquality() {
    #expect(java.nio.ByteOrder.BIG_ENDIAN == java.nio.ByteOrder.BIG_ENDIAN)
    #expect(java.nio.ByteOrder.LITTLE_ENDIAN == java.nio.ByteOrder.LITTLE_ENDIAN)
    #expect(java.nio.ByteOrder.BIG_ENDIAN != java.nio.ByteOrder.LITTLE_ENDIAN)
  }

  @Test("ByteOrder.equals()")
  func testEqualsMethod() {
    #expect(java.nio.ByteOrder.BIG_ENDIAN.equals(java.nio.ByteOrder.BIG_ENDIAN))
    #expect(!java.nio.ByteOrder.BIG_ENDIAN.equals(java.nio.ByteOrder.LITTLE_ENDIAN))
  }

  @Test("ByteOrder.nativeOrder() liefert BIG_ENDIAN oder LITTLE_ENDIAN")
  func testNativeOrder() {
    let native = java.nio.ByteOrder.nativeOrder()
    let isKnown = (native == .BIG_ENDIAN) || (native == .LITTLE_ENDIAN)
    #expect(isKnown)
  }
}

// MARK: - ByteBuffer Tests

struct JavApi_nio_ByteBuffer_Tests {

  @Test("allocate mit gültiger Größe erzeugt leeren Buffer")
  func testAllocate() throws {
    let buf = try ByteBuffer.allocate(16)
    let arr = try buf.array() as [UInt8]
    #expect(arr.isEmpty)
  }

  @Test("allocate mit Größe 0 ist erlaubt")
  func testAllocateZero() throws {
    let buf = try ByteBuffer.allocate(0)
    let arr = try buf.array() as [UInt8]
    #expect(arr.isEmpty)
  }

  @Test("allocate mit negativer Größe wirft IllegalArgumentException")
  func testAllocateNegative() throws {
    #expect(throws: IllegalArgumentException.self) {
      try ByteBuffer.allocate(-1)
    }
  }

  @Test("put(byte) hängt Byte an")
  func testPutSingleByte() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put(UInt8(0x42))
    let arr = try buf.array() as [UInt8]
    #expect(arr == [0x42])
  }

  @Test("put(byte) ist chainbar")
  func testPutChaining() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put(UInt8(1)).put(UInt8(2)).put(UInt8(3))
    let arr = try buf.array() as [UInt8]
    #expect(arr == [1, 2, 3])
  }

  @Test("put([UInt8]) hängt Array an")
  func testPutByteArray() throws {
    let buf = try ByteBuffer.allocate(8)
    _ = try buf.put([UInt8(10), UInt8(20), UInt8(30)])
    let arr = try buf.array() as [UInt8]
    #expect(arr == [10, 20, 30])
  }

  @Test("put([UInt8], offset, length) übernimmt Teilbereich")
  func testPutWithOffsetAndLength() throws {
    let buf = try ByteBuffer.allocate(8)
    _ = try buf.put([UInt8(1), UInt8(2), UInt8(3), UInt8(4), UInt8(5)], 1, 3)
    let arr = try buf.array() as [UInt8]
    #expect(arr == [2, 3, 4])
  }

  @Test("put mit negativem Offset wirft IndexOutOfBoundsException")
  func testPutNegativeOffset() throws {
    let buf = try ByteBuffer.allocate(4)
    #expect(throws: IndexOutOfBoundsException.self) {
      try buf.put([UInt8(1), UInt8(2)], -1, 1)
    }
  }

  @Test("put mit Offset außerhalb des Arrays wirft IndexOutOfBoundsException")
  func testPutOffsetOutOfBounds() throws {
    let buf = try ByteBuffer.allocate(4)
    #expect(throws: IndexOutOfBoundsException.self) {
      try buf.put([UInt8(1), UInt8(2)], 5, 1)
    }
  }

  @Test("put mit length > verbleibende Bytes wirft IndexOutOfBoundsException")
  func testPutLengthTooLarge() throws {
    let buf = try ByteBuffer.allocate(4)
    #expect(throws: IndexOutOfBoundsException.self) {
      try buf.put([UInt8(1), UInt8(2), UInt8(3)], 1, 5)
    }
  }

  @Test("put mit negativer length wirft IndexOutOfBoundsException")
  func testPutNegativeLength() throws {
    let buf = try ByteBuffer.allocate(4)
    #expect(throws: IndexOutOfBoundsException.self) {
      try buf.put([UInt8(1), UInt8(2)], 0, -1)
    }
  }

  // MARK: - ByteOrder im ByteBuffer

  @Test("Standard-ByteOrder ist BIG_ENDIAN")
  func testDefaultByteOrder() throws {
    let buf = try ByteBuffer.allocate(4)
    #expect(buf.order() == java.nio.ByteOrder.BIG_ENDIAN)
  }

  @Test("order() Wechsel zu LITTLE_ENDIAN kehrt Inhalt um")
  func testOrderSwitch() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put([UInt8(1), UInt8(2), UInt8(3)])
    _ = buf.order(java.nio.ByteOrder.LITTLE_ENDIAN)
    #expect(buf.order() == java.nio.ByteOrder.LITTLE_ENDIAN)
    let arr = try buf.array() as [UInt8]
    #expect(arr == [3, 2, 1])
  }

  @Test("order() Wechsel zweimal ergibt ursprüngliche Reihenfolge")
  func testOrderSwitchTwice() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put([UInt8(0xAA), UInt8(0xBB), UInt8(0xCC)])
    _ = buf.order(java.nio.ByteOrder.LITTLE_ENDIAN)
    _ = buf.order(java.nio.ByteOrder.BIG_ENDIAN)
    #expect(buf.order() == java.nio.ByteOrder.BIG_ENDIAN)
    let arr = try buf.array() as [UInt8]
    #expect(arr == [0xAA, 0xBB, 0xCC])
  }

  @Test("order() mit gleichem Wert ist idempotent (kein Umkehren)")
  func testOrderIdempotent() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put([UInt8(1), UInt8(2), UInt8(3)])
    _ = buf.order(java.nio.ByteOrder.BIG_ENDIAN) // bereits BIG_ENDIAN
    let arr = try buf.array() as [UInt8]
    #expect(arr == [1, 2, 3])
  }

  // MARK: - array() als Data (Swiftify)

  @Test("array() als Data gibt Foundation Data zurück")
  func testArrayAsData() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put([UInt8(0xDE), UInt8(0xAD)])
    let data: Data = buf.array()
    #expect(data == Data([0xDE, 0xAD]))
  }
}
