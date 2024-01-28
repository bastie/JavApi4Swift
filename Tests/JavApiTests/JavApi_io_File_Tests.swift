/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

final class JavApi_io_File_Tests: XCTestCase {
  
  func testCanExceute () {
#if os(macOS)
    // true positive
    XCTAssertTrue(java.io.File("/Applications/Safari.app").canExecute(), "Safari not executable")
    // true negative
    XCTAssertFalse(java.io.File("/Applications/Internet Explorer.app").canExecute(), "Internet Explorer executable")
#else
    // TODO: Test missing for java.io.File on other platforms
#endif
  }
  
  func testCanRead () {
#if os(macOS)
    // true positive
    XCTAssertTrue(java.io.File("/Applications/Safari.app").canRead(), "Safari not readable")
    // true negative
    XCTAssertFalse(java.io.File("/Applications/Internet Explorer.app").canRead(), "Internet Explorer readable")
#else
    // TODO: Test missing for java.io.File on other platforms
#endif
  }
  
  func testCanWrite () {
#if os(macOS)
    // true positive
    XCTAssertTrue(java.io.File("/Users/Shared").canWrite(), "Shared User not writable")
    // true negative
    XCTAssertFalse(java.io.File("/Applications/Safari.app").canWrite(), "System Safari is writable")
#else
    // TODO: Test missing for java.io.File on other platforms
#endif
  }
  
  func testIsDirectory () {
#if os(macOS)
    // true positive
    XCTAssertTrue(java.io.File("/Applications/Safari.app").isDirectory(), "Safari.app isn't a directory")
    // true negative
    XCTAssertFalse(java.io.File("/Applications/!Safari.app").isDirectory(), "!Safari.app exists and is a directory")
    XCTAssertFalse(java.io.File("/Application/Safari.app/Contents/Info.plist").isDirectory(), "Info.plist exists and is a directory")
#else
    // TODO: Test missing for java.io.File on other platforms
#endif
  }
  
  func testIsHidden () {
#if os(macOS)
    // true positive
    XCTAssertTrue(java.io.File("/.file").isHidden(), "Safari.app is hidden")
    // true negative
    XCTAssertFalse(java.io.File("/Applications/Safari.app").isHidden(), "Safari.app isn't hidden")
    XCTAssertFalse(java.io.File("/.bastie").isHidden(), "/.bastie isn't hidden")
#else
    // TODO: Test missing for java.io.File on other platforms
#endif
  }
}
