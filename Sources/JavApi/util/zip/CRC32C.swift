/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.zip {
  /// cyclic redundancy check with 32 bit (CRC-32) checksum algorithm
  final public class CRC32C : Checksum {
    
    private var v : Int64 = 0
    
    public func reset() {
      v = 0
    }
    
    public func getValue() -> Int64 {
      return v
    }
    
    public typealias Checksum = CRC32C
    
    
    public func update(_ buf: [UInt8], _ index: Int, _ len: Int) {
      let reversedPolynomial: UInt32 = 0x82f6_3b78
      var crc: UInt32 = 0 ^ 0xffff_ffff
      
      for i in index..<index+len {
        crc ^= UInt32(buf[i])
        crc = ((crc & 1) != 0) ? (crc >> 1) ^ reversedPolynomial : crc >> 1
        crc = ((crc & 1) != 0) ? (crc >> 1) ^ reversedPolynomial : crc >> 1
        crc = ((crc & 1) != 0) ? (crc >> 1) ^ reversedPolynomial : crc >> 1
        crc = ((crc & 1) != 0) ? (crc >> 1) ^ reversedPolynomial : crc >> 1
        crc = ((crc & 1) != 0) ? (crc >> 1) ^ reversedPolynomial : crc >> 1
        crc = ((crc & 1) != 0) ? (crc >> 1) ^ reversedPolynomial : crc >> 1
        crc = ((crc & 1) != 0) ? (crc >> 1) ^ reversedPolynomial : crc >> 1
        crc = ((crc & 1) != 0) ? (crc >> 1) ^ reversedPolynomial : crc >> 1
      }
      crc = crc ^ 0xffff_ffff
      
      v = Int64(crc)
    }
  }
}
