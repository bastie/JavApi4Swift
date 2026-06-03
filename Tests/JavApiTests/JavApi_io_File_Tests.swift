/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
import Testing
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
  
  func testGetAbsoluteFilePath () {
#if os(macOS)
    XCTAssertEqual(java.io.File("/Applications/Safari.app").getAbsolutePath(), "/Applications/Safari.app")
    XCTAssertEqual(java.io.File("/Applications/./Safari.app").getAbsolutePath(), "/Applications/./Safari.app")
    XCTAssertEqual(java.io.File("/Applications/../Applications/Safari.app").getAbsolutePath(), "/Applications/../Applications/Safari.app")
#else
    // TODO: Test missing for java.io.File on other platforms
#endif
  }
  
  /// Test agains JavApi 0.12.0 bug.
  func testListFiles () {
    let absoluteDir = "/Applications"
    let appDir = java.io.File(absoluteDir)
    if let apps = appDir.listFiles() {
      for app in apps {
        XCTAssert(app.getAbsolutePath().startsWith(absoluteDir))
      }
    }
  }
  class AppFilter : java.io.FileFilter {
    func accept(_ file: JavApi.java.io.File) -> Bool {
      return file.getName().endsWith(".app") && file.isDirectory()
    }
    typealias FileFilter = AppFilter
  }
  /// Test agains JavApi 0.12.0 bug.
  func testListFilesWithFileFilter () {
    let absoluteDir = "/Applications"
    let appDir = java.io.File(absoluteDir)
    if let apps = appDir.listFiles (AppFilter()) {
      for app in apps {
        XCTAssert(app.getAbsolutePath().startsWith(absoluteDir))
        XCTAssert(app.getAbsolutePath().hasSuffix(".app"))
      }
    }
  }

}

// MARK: - Cross-platform tests (Swift Testing)

struct JavApi_io_File_CrossPlatform_Tests {

  @Test("non-existent file reports all capabilities as false")
  func testNonExistentFile() {
    let f = java.io.File("/this/path/does/not/exist/ever")
    #expect(!f.isDirectory())
    #expect(!f.canExecute())
    #expect(!f.canRead())
    #expect(f.listFiles() == nil)
  }

  @Test("getName extracts the last path component")
  func testGetName() {
    #expect(java.io.File("/foo/bar/baz.txt").getName() == "baz.txt")
    #expect(java.io.File("baz.txt").getName() == "baz.txt")
  }

  @Test("/tmp is a readable directory on macOS and Linux")
  func testListFilesOnTmpDir() {
    let tmpDir = java.io.File("/tmp")
    #expect(tmpDir.isDirectory())
    #expect(tmpDir.listFiles() != nil)
  }
}
