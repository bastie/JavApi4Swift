/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
public protocol DataInput {
  
  func readBoolean() throws -> Bool
  func readByte() throws -> Int8
  func readChar() throws -> Character
  func readDouble() throws -> Double
  func readFloat() throws -> Float
  func readFully(_ buffer: inout [UInt8]) throws
  func readFully(_ buffer: inout [UInt8], _ offset : Int, _ length : Int) throws
  func readInt() throws -> Int
  func readLine() throws -> String
  func readLong() throws -> Int64
  func readShort() throws -> Int16
  func readUnsignedByte() throws -> Int
  func readUnsignedShort() throws -> Int
  func readUTF() throws -> String
  func skipBytes(_ n: Int) throws
}
