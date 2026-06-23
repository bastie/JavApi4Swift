/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Boolean

struct JavApi_io_DataStreams_Boolean_Tests {

  @Test("writeBoolean/readBoolean round-trip: true")
  func roundTripTrue() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeBoolean(true)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readBoolean() == true)
  }

  @Test("writeBoolean/readBoolean round-trip: false")
  func roundTripFalse() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeBoolean(false)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readBoolean() == false)
  }

  @Test("readBoolean on empty stream throws EOFException")
  func readBooleanEOF() throws {
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream([]))
    #expect(throws: (any Error).self) { try din.readBoolean() }
  }

  @Test("writeBoolean true encodes as byte 1")
  func writeBooleanEncoding() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeBoolean(true)
    #expect(buf.toByteArray() == [1])
  }

  @Test("writeBoolean false encodes as byte 0")
  func writeBooleanFalseEncoding() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeBoolean(false)
    #expect(buf.toByteArray() == [0])
  }
}

// MARK: - Byte

struct JavApi_io_DataStreams_Byte_Tests {

  @Test("writeByte/readByte round-trip: positive value")
  func roundTripPositive() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeByte(42)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readByte() == 42)
  }

  @Test("writeByte/readByte round-trip: negative value (-1 → 0xFF)")
  func roundTripNegative() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeByte(-1)   // writes 0xFF
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readByte() == -1)
  }

  @Test("readUnsignedByte returns 0–255")
  func readUnsignedByte() throws {
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream([0xFF]))
    #expect(try din.readUnsignedByte() == 255)
  }

  @Test("readByte on empty stream throws EOFException")
  func readByteEOF() {
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream([]))
    #expect(throws: (any Error).self) { try din.readByte() }
  }
}

// MARK: - Short

struct JavApi_io_DataStreams_Short_Tests {

  @Test("writeShort/readShort round-trip: 1000")
  func roundTrip() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeShort(1000)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readShort() == 1000)
  }

  @Test("writeShort encodes big-endian")
  func bigEndianEncoding() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeShort(0x0102)
    #expect(buf.toByteArray() == [0x01, 0x02])
  }

  @Test("writeShort/readUnsignedShort: max unsigned value 65535")
  func unsignedShortMax() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeShort(65535)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readUnsignedShort() == 65535)
  }

  @Test("readShort on empty stream throws EOFException")
  func readShortEOF() {
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream([]))
    #expect(throws: (any Error).self) { try din.readShort() }
  }

  @Test("readShort on incomplete data (1 byte) throws EOFException")
  func readShortPartialEOF() {
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream([0x01]))
    #expect(throws: (any Error).self) { try din.readShort() }
  }
}

// MARK: - Int

struct JavApi_io_DataStreams_Int_Tests {

  @Test("writeInt/readInt round-trip: 42")
  func roundTrip42() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeInt(42)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readInt() == 42)
  }

  @Test("writeInt encodes big-endian: 0x01020304")
  func bigEndianEncoding() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeInt(0x01020304)
    #expect(buf.toByteArray() == [0x01, 0x02, 0x03, 0x04])
  }

  @Test("writeInt/readInt round-trip: Int.min")
  func roundTripMinValue() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeInt(Int(Int32.min))
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readInt() == Int(Int32.min))
  }

  @Test("writeInt/readInt round-trip: -1")
  func roundTripNegativeOne() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeInt(-1)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readInt() == -1)
  }

  @Test("readInt on empty stream throws EOFException")
  func readIntEOF() {
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream([]))
    #expect(throws: (any Error).self) { try din.readInt() }
  }
}

// MARK: - Long

struct JavApi_io_DataStreams_Long_Tests {

  @Test("writeLong/readLong round-trip: 0")
  func roundTripZero() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeLong(0)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readLong() == 0)
  }

  @Test("writeLong/readLong round-trip: Int64.max")
  func roundTripMax() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeLong(Int64.max)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readLong() == Int64.max)
  }

  @Test("writeLong/readLong round-trip: Int64.min")
  func roundTripMin() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeLong(Int64.min)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readLong() == Int64.min)
  }

  @Test("writeLong encodes 8 bytes big-endian")
  func encodesEightBytes() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeLong(1)
    #expect(buf.toByteArray() == [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01])
  }

  @Test("readLong on empty stream throws EOFException")
  func readLongEOF() {
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream([]))
    #expect(throws: (any Error).self) { try din.readLong() }
  }
}

// MARK: - Float

struct JavApi_io_DataStreams_Float_Tests {

  @Test("writeFloat/readFloat round-trip: 3.14")
  func roundTrip() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeFloat(3.14)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readFloat() == 3.14)
  }

  @Test("writeFloat/readFloat round-trip: negative value")
  func roundTripNegative() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeFloat(-1.5)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readFloat() == -1.5)
  }

  @Test("writeFloat/readFloat round-trip: 0.0")
  func roundTripZero() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeFloat(0.0)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readFloat() == 0.0)
  }

  @Test("writeFloat encodes 4 bytes")
  func encodesFourBytes() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeFloat(0.0)
    #expect(buf.toByteArray().count == 4)
  }

  @Test("readFloat on empty stream throws EOFException")
  func readFloatEOF() {
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream([]))
    #expect(throws: (any Error).self) { try din.readFloat() }
  }
}

// MARK: - Double

struct JavApi_io_DataStreams_Double_Tests {

  @Test("writeDouble/readDouble round-trip: 3.141592653589793")
  func roundTrip() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeDouble(3.141592653589793)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readDouble() == 3.141592653589793)
  }

  @Test("writeDouble/readDouble round-trip: Double.infinity")
  func roundTripInfinity() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeDouble(Double.infinity)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readDouble() == Double.infinity)
  }

  @Test("writeDouble/readDouble round-trip: -Double.infinity")
  func roundTripNegativeInfinity() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeDouble(-Double.infinity)
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readDouble() == -Double.infinity)
  }

  @Test("writeDouble encodes 8 bytes")
  func encodesEightBytes() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeDouble(0.0)
    #expect(buf.toByteArray().count == 8)
  }

  @Test("readDouble on empty stream throws EOFException")
  func readDoubleEOF() {
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream([]))
    #expect(throws: (any Error).self) { try din.readDouble() }
  }
}

// MARK: - Char

struct JavApi_io_DataStreams_Char_Tests {

  @Test("writeChar/readChar round-trip: 'A'")
  func roundTripA() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeChar(Int(("A" as UnicodeScalar).value))
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readChar() == "A")
  }

  @Test("writeChar encodes 2 bytes big-endian")
  func encodesTwoBytes() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeChar(0x0041)  // 'A'
    #expect(buf.toByteArray() == [0x00, 0x41])
  }

  @Test("readChar on empty stream throws EOFException")
  func readCharEOF() {
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream([]))
    #expect(throws: (any Error).self) { try din.readChar() }
  }
}

// MARK: - UTF

struct JavApi_io_DataStreams_UTF_Tests {

  @Test("writeUTF/readUTF round-trip: ASCII string")
  func roundTripASCII() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeUTF("hello")
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readUTF() == "hello")
  }

  @Test("writeUTF/readUTF round-trip: empty string")
  func roundTripEmpty() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeUTF("")
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readUTF() == "")
  }

  @Test("writeUTF/readUTF round-trip: Unicode string")
  func roundTripUnicode() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeUTF("Ünïcödé")
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readUTF() == "Ünïcödé")
  }

  @Test("writeUTF length prefix is 2-byte big-endian byte count")
  func lengthPrefix() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeUTF("AB")
    let bytes = buf.toByteArray()
    // bytes 0-1: length prefix (2 = 0x00 0x02), bytes 2-3: 'A' 'B'
    #expect(bytes[0] == 0x00)
    #expect(bytes[1] == 0x02)
    #expect(bytes.count == 4)
  }
}

// MARK: - readFully

struct JavApi_io_DataStreams_ReadFully_Tests {

  @Test("readFully fills buffer completely")
  func readFullyFillsBuffer() throws {
    let data: [UInt8] = [1, 2, 3, 4, 5]
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(data))
    var buf = [UInt8](repeating: 0, count: 5)
    try din.readFully(&buf)
    #expect(buf == data)
  }

  @Test("readFully with offset and length reads correct slice")
  func readFullyWithOffsetAndLength() throws {
    let data: [UInt8] = [10, 20, 30, 40, 50]
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(data))
    var buf = [UInt8](repeating: 0, count: 5)
    try din.readFully(&buf, 1, 3)
    #expect(buf[1] == 10)
    #expect(buf[2] == 20)
    #expect(buf[3] == 30)
  }

  @Test("readFully on too-short stream throws EOFException")
  func readFullyEOF() {
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream([1, 2]))
    var buf = [UInt8](repeating: 0, count: 5)
    #expect(throws: (any Error).self) { try din.readFully(&buf) }
  }
}

// MARK: - skipBytes

struct JavApi_io_DataStreams_SkipBytes_Tests {

  @Test("skipBytes advances stream position")
  func skipAdvancesPosition() throws {
    let data: [UInt8] = [1, 2, 3, 4, 5]
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(data))
    try din.skipBytes(3)
    #expect(try din.readByte() == 4)
  }

  @Test("skipBytes 0 does not advance")
  func skipZero() throws {
    let data: [UInt8] = [42]
    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(data))
    try din.skipBytes(0)
    #expect(try din.readByte() == 42)
  }
}

// MARK: - DataOutputStream.size / written

struct JavApi_io_DataStreams_Size_Tests {

  @Test("size() returns total bytes written")
  func sizeTracksTotalBytesWritten() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    #expect(dout.size() == 0)
    try dout.writeInt(1)
    #expect(dout.size() == 4)
    try dout.writeLong(1)
    #expect(dout.size() == 12)
  }

  @Test("written property matches size()")
  func writtenMatchesSize() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeBoolean(true)
    try dout.writeShort(0)
    #expect(dout.written == dout.size())
    #expect(dout.written == 3)
  }
}

// MARK: - Multi-type round-trip

struct JavApi_io_DataStreams_MultiType_Tests {

  @Test("Mixed types written and read back in order")
  func mixedTypesRoundTrip() throws {
    let buf = java.io.ByteArrayOutputStream()
    let dout = java.io.DataOutputStream(buf)
    try dout.writeBoolean(true)
    try dout.writeByte(127)
    try dout.writeShort(1000)
    try dout.writeInt(100_000)
    try dout.writeLong(Int64(9_000_000_000))
    try dout.writeFloat(1.5)
    try dout.writeDouble(2.718281828)
    try dout.writeUTF("test")

    let din = java.io.DataInputStream(java.io.ByteArrayInputStream(buf.toByteArray()))
    #expect(try din.readBoolean() == true)
    #expect(try din.readByte() == 127)
    #expect(try din.readShort() == 1000)
    #expect(try din.readInt() == 100_000)
    #expect(try din.readLong() == Int64(9_000_000_000))
    #expect(try din.readFloat() == 1.5)
    #expect(try din.readDouble() == 2.718281828)
    #expect(try din.readUTF() == "test")
  }
}
