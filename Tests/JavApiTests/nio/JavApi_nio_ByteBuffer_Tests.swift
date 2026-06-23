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
    #expect(java.nio.ByteOrder.BIG_ENDIAN.toString() == "BIG_ENDIAN")
    #expect(java.nio.ByteOrder.LITTLE_ENDIAN.toString() == "LITTLE_ENDIAN")
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
    #expect((native == .BIG_ENDIAN) || (native == .LITTLE_ENDIAN))
  }
}

// MARK: - ByteBuffer: allocate

struct JavApi_nio_ByteBuffer_Allocate_Tests {

  @Test("allocate(0) erzeugt leeren Buffer – capacity/limit/position alle 0")
  func testAllocateZero() throws {
    let buf = try ByteBuffer.allocate(0)
    #expect(buf.capacity() == 0)
    #expect(buf.limit() == 0)
    #expect(buf.position() == 0)
    let arr = try buf.array() as [UInt8]
    #expect(arr.isEmpty)
  }

  @Test("allocate(n) füllt Buffer mit n Nullbytes – wie Java")
  func testAllocateFillsWithZeros() throws {
    let buf = try ByteBuffer.allocate(4)
    #expect(buf.capacity() == 4)
    #expect(buf.limit() == 4)
    #expect(buf.position() == 0)
    let arr = try buf.array() as [UInt8]
    #expect(arr == [0, 0, 0, 0])
  }

  @Test("allocate mit negativer Größe wirft IllegalArgumentException")
  func testAllocateNegative() {
    #expect(throws: IllegalArgumentException.self) {
      try ByteBuffer.allocate(-1)
    }
  }
}

// MARK: - ByteBuffer: wrap

struct JavApi_nio_ByteBuffer_Wrap_Tests {

  @Test("wrap(array) setzt capacity/limit=array.count, position=0")
  func testWrapArray() throws {
    let buf = ByteBuffer.wrap([UInt8(1), UInt8(2), UInt8(3)])
    #expect(buf.capacity() == 3)
    #expect(buf.limit() == 3)
    #expect(buf.position() == 0)
    let arr = try buf.array() as [UInt8]
    #expect(arr == [1, 2, 3])
  }

  @Test("wrap(array, offset, length) setzt position=offset, limit=offset+length")
  func testWrapWithOffsetAndLength() throws {
    let buf = ByteBuffer.wrap([UInt8(1), UInt8(2), UInt8(3), UInt8(4)], 1, 2)
    #expect(buf.capacity() == 4)
    #expect(buf.position() == 1)
    #expect(buf.limit() == 3)
  }
}

// MARK: - ByteBuffer: capacity / limit / position / remaining

struct JavApi_nio_ByteBuffer_State_Tests {

  @Test("remaining() = limit - position")
  func testRemaining() throws {
    let buf = try ByteBuffer.allocate(8)
    #expect(buf.remaining() == 8)
    _ = try buf.put(UInt8(1))
    #expect(buf.remaining() == 7)
  }

  @Test("hasRemaining() true wenn position < limit")
  func testHasRemainingTrue() throws {
    let buf = try ByteBuffer.allocate(4)
    #expect(buf.hasRemaining())
  }

  @Test("hasRemaining() false wenn position == limit")
  func testHasRemainingFalseWhenFull() throws {
    let buf = try ByteBuffer.allocate(2)
    _ = try buf.put(UInt8(1))
    _ = try buf.put(UInt8(2))
    #expect(!buf.hasRemaining())
  }

  @Test("position(n) setzt Position")
  func testSetPosition() throws {
    let buf = try ByteBuffer.allocate(8)
    _ = try buf.position(3)
    #expect(buf.position() == 3)
    #expect(buf.remaining() == 5)
  }

  @Test("position(-1) wirft IllegalArgumentException")
  func testSetPositionNegative() throws {
    let buf = try ByteBuffer.allocate(8)
    #expect(throws: IllegalArgumentException.self) {
      try buf.position(-1)
    }
  }

  @Test("position(n > limit) wirft IllegalArgumentException")
  func testSetPositionBeyondLimit() throws {
    let buf = try ByteBuffer.allocate(4)
    #expect(throws: IllegalArgumentException.self) {
      try buf.position(5)
    }
  }

  @Test("limit(n) setzt Limit")
  func testSetLimit() throws {
    let buf = try ByteBuffer.allocate(8)
    _ = try buf.limit(4)
    #expect(buf.limit() == 4)
    #expect(buf.remaining() == 4)
  }

  @Test("limit(n > capacity) wirft IllegalArgumentException")
  func testSetLimitBeyondCapacity() throws {
    let buf = try ByteBuffer.allocate(4)
    #expect(throws: IllegalArgumentException.self) {
      try buf.limit(10)
    }
  }

  @Test("limit(n < position) setzt position auf neues limit")
  func testSetLimitBelowPosition() throws {
    let buf = try ByteBuffer.allocate(8)
    _ = try buf.position(6)
    _ = try buf.limit(3)
    #expect(buf.limit() == 3)
    #expect(buf.position() == 3) // position wird auf limit geklemmt
  }
}

// MARK: - ByteBuffer: put

struct JavApi_nio_ByteBuffer_Put_Tests {

  @Test("put schreibt an Position 0 – nicht ans Ende (Java-Semantik)")
  func testPutWritesAtPosition() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put(UInt8(0x42))
    let arr = try buf.array() as [UInt8]
    #expect(arr == [0x42, 0, 0, 0])
  }

  @Test("put rückt position vor")
  func testPutAdvancesPosition() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put(UInt8(1))
    _ = try buf.put(UInt8(2))
    #expect(buf.position() == 2)
    #expect(buf.remaining() == 2)
  }

  @Test("put ist chainbar")
  func testPutChaining() throws {
    let buf = try ByteBuffer.allocate(3)
    _ = try buf.put(UInt8(1)).put(UInt8(2)).put(UInt8(3))
    let arr = try buf.array() as [UInt8]
    #expect(arr == [1, 2, 3])
  }

  @Test("put bei vollem Buffer wirft BufferOverflowException")
  func testPutOverflow() throws {
    let buf = try ByteBuffer.allocate(2)
    _ = try buf.put(UInt8(1))
    _ = try buf.put(UInt8(2))
    #expect(throws: java.nio.BufferOverflowException.self) {
      try buf.put(UInt8(3))
    }
  }

  @Test("put([UInt8]) schreibt Array ab aktueller Position")
  func testPutArray() throws {
    let buf = try ByteBuffer.allocate(5)
    _ = try buf.put([UInt8(10), UInt8(20), UInt8(30)])
    let arr = try buf.array() as [UInt8]
    #expect(arr == [10, 20, 30, 0, 0])
    #expect(buf.position() == 3)
  }

  @Test("put(array, offset, length) übernimmt Teilbereich")
  func testPutWithOffsetAndLength() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put([UInt8(1), UInt8(2), UInt8(3), UInt8(4), UInt8(5)], 1, 3)
    let arr = try buf.array() as [UInt8]
    #expect(arr == [2, 3, 4, 0])
  }

  @Test("put(array, offset, 0) ist No-op")
  func testPutLengthZeroIsNoOp() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put([UInt8(1), UInt8(2)], 0, 0)
    #expect(buf.position() == 0)
  }

  @Test("put([], 0, 0) auf leerem Array ist No-op – wie Java")
  func testPutEmptyArrayZeroZero() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put([], 0, 0)
    #expect(buf.position() == 0)
  }

  @Test("put mit offset am Arrayende und length=0 ist No-op – wie Java")
  func testPutOffsetAtEndLengthZero() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put([UInt8(1), UInt8(2), UInt8(3)], 3, 0)
    #expect(buf.position() == 0)
  }

  @Test("put mit negativem Offset wirft IndexOutOfBoundsException")
  func testPutNegativeOffset() throws {
    let buf = try ByteBuffer.allocate(4)
    #expect(throws: IndexOutOfBoundsException.self) {
      try buf.put([UInt8(1), UInt8(2)], -1, 1)
    }
  }

  @Test("put mit offset+length > Arraygröße wirft IndexOutOfBoundsException")
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
}

// MARK: - ByteBuffer: get

struct JavApi_nio_ByteBuffer_Get_Tests {

  @Test("get() liest an aktueller Position und rückt vor")
  func testGetReadsAndAdvances() throws {
    let buf = try ByteBuffer.allocate(3)
    _ = try buf.put(UInt8(10))
    _ = try buf.put(UInt8(20))
    _ = try buf.put(UInt8(30))
    _ = buf.flip()
    #expect(try buf.get() == 10)
    #expect(try buf.get() == 20)
    #expect(try buf.get() == 30)
    #expect(buf.position() == 3)
  }

  @Test("get(index) liest absolut ohne position zu verändern")
  func testGetAbsolute() throws {
    let buf = try ByteBuffer.allocate(3)
    _ = try buf.put(UInt8(10))
    _ = try buf.put(UInt8(20))
    _ = try buf.put(UInt8(30))
    #expect(try buf.get(1) == 20)
    #expect(buf.position() == 3) // unverändert
  }

  @Test("get() am Bufferende wirft BufferUnderflowException")
  func testGetUnderflow() throws {
    let buf = try ByteBuffer.allocate(1)
    _ = try buf.put(UInt8(42))
    _ = buf.flip()
    _ = try buf.get()
    #expect(throws: java.nio.BufferUnderflowException.self) {
      try buf.get()
    }
  }

  @Test("get(index) außerhalb limit wirft IndexOutOfBoundsException")
  func testGetAbsoluteOutOfBounds() throws {
    let buf = try ByteBuffer.allocate(3)
    #expect(throws: IndexOutOfBoundsException.self) {
      try buf.get(5)
    }
  }
}

// MARK: - ByteBuffer: flip / clear / rewind

struct JavApi_nio_ByteBuffer_FlipClearRewind_Tests {

  @Test("flip: limit ← position, position ← 0")
  func testFlip() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put(UInt8(1))
    _ = try buf.put(UInt8(2))
    _ = buf.flip()
    #expect(buf.limit() == 2)
    #expect(buf.position() == 0)
    #expect(buf.remaining() == 2)
  }

  @Test("clear: position ← 0, limit ← capacity")
  func testClear() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put(UInt8(1))
    _ = try buf.put(UInt8(2))
    _ = buf.flip()
    _ = buf.clear()
    #expect(buf.position() == 0)
    #expect(buf.limit() == 4)
    #expect(buf.capacity() == 4)
  }

  @Test("rewind: position ← 0, limit unverändert")
  func testRewind() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put(UInt8(1))
    _ = try buf.put(UInt8(2))
    _ = buf.rewind()
    #expect(buf.position() == 0)
    #expect(buf.limit() == 4)
  }
}

// MARK: - ByteBuffer: byte order

struct JavApi_nio_ByteBuffer_Order_Tests {

  @Test("Standard-ByteOrder ist BIG_ENDIAN – wie Java")
  func testDefaultByteOrder() throws {
    let buf = try ByteBuffer.allocate(4)
    #expect(buf.order() == java.nio.ByteOrder.BIG_ENDIAN)
  }

  @Test("order() ändert Eigenschaft ohne Bytes zu verändern – wie Java")
  func testOrderDoesNotChangeContent() throws {
    let buf = try ByteBuffer.allocate(3)
    _ = try buf.put(UInt8(1))
    _ = try buf.put(UInt8(2))
    _ = try buf.put(UInt8(3))
    _ = buf.order(java.nio.ByteOrder.LITTLE_ENDIAN)
    #expect(buf.order() == java.nio.ByteOrder.LITTLE_ENDIAN)
    let arr = try buf.array() as [UInt8]
    #expect(arr == [1, 2, 3])
  }

  @Test("order() ist idempotent")
  func testOrderIdempotent() throws {
    let buf = try ByteBuffer.allocate(3)
    _ = buf.order(java.nio.ByteOrder.BIG_ENDIAN)
    #expect(buf.order() == java.nio.ByteOrder.BIG_ENDIAN)
  }
}

// MARK: - ByteBuffer: array() als Data (Swiftify)

struct JavApi_nio_ByteBuffer_Swiftify_Tests {

  @Test("array() als Data gibt Foundation Data zurück")
  func testArrayAsData() throws {
    let buf = try ByteBuffer.allocate(2)
    _ = try buf.put(UInt8(0xDE))
    _ = try buf.put(UInt8(0xAD))
    let data: Data = buf.array()
    #expect(data == Data([0xDE, 0xAD]))
  }
}

// MARK: - ByteBuffer: typischer Java-Zyklus

struct JavApi_nio_ByteBuffer_Lifecycle_Tests {

  @Test("typischer Schreib-Flip-Lese-Zyklus – wie Java")
  func testWriteFlipReadCycle() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put(UInt8(0xAA))
    _ = try buf.put(UInt8(0xBB))
    _ = try buf.put(UInt8(0xCC))
    _ = buf.flip()
    #expect(try buf.get() == 0xAA)
    #expect(try buf.get() == 0xBB)
    #expect(try buf.get() == 0xCC)
    #expect(!buf.hasRemaining())
  }

  @Test("clear nach flip erlaubt neuen Schreibzyklus")
  func testClearAfterFlipAllowsRewrite() throws {
    let buf = try ByteBuffer.allocate(4)
    _ = try buf.put(UInt8(1))
    _ = try buf.put(UInt8(2))
    _ = buf.flip()
    _ = buf.clear()
    _ = try buf.put(UInt8(9))
    _ = try buf.put(UInt8(8))
    _ = buf.flip()
    #expect(try buf.get() == 9)
    #expect(try buf.get() == 8)
  }

  @Test("rewind erlaubt erneutes Lesen derselben Daten")
  func testRewindAllowsRereading() throws {
    let buf = try ByteBuffer.allocate(3)
    _ = try buf.put(UInt8(7))
    _ = try buf.put(UInt8(8))
    _ = try buf.put(UInt8(9))
    _ = buf.flip()
    _ = try buf.get()
    _ = try buf.get()
    _ = buf.rewind()
    #expect(try buf.get() == 7)
  }
}
