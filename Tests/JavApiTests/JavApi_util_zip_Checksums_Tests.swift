/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi
import CryptoKit

final class JavApi_util_zip_checksum_Tests: XCTestCase {
  func testAdler32 () {
    let chksum : any Checksum = java.util.zip.Adler32()
    
    let input = Array ("HELLO".utf8)
    chksum.update(input, 0, input.count)
    let actually = chksum.getValue()
    let expected = Int64 (72089973)
    XCTAssertEqual(expected, actually, "Adler32 Prüfsummenberechnung fehlerhaft")
  }
    
  func testCRC32 () {
    let chksum : any Checksum = java.util.zip.CRC32()
    
    let input = Array ("HELLO".utf8)
    chksum.update(input, 0, input.count)
    let actually = chksum.getValue()
    let expected = Int64 (3242484790)
    XCTAssertEqual(expected, actually, "CRC32 Prüfsummenberechnung fehlerhaft")
  }

  
  func testCRC32C () {
    let chksum : any Checksum = java.util.zip.CRC32C()
    
    let input = Array ("HELLO".utf8)
    chksum.update(input, 0, input.count)
    let actually = chksum.getValue()
    let expected = Int64 (3901656152)
    XCTAssertEqual(expected, actually, "CRC32C Prüfsummenberechnung fehlerhaft")
  }
  

  func testSwiftlyAdler32 () {
    let _ = Insecure.Adler32 ()
  }
}
