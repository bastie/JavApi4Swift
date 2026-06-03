/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - macOS-specific tests

struct JavApi_io_File_Tests {

  @Test("canExecute returns true for Safari, false for non-existent app")
  func testCanExecute() {
#if os(macOS)
    #expect(java.io.File("/Applications/Safari.app").canExecute())
    #expect(!java.io.File("/Applications/Internet Explorer.app").canExecute())
#endif
  }

  @Test("canRead returns true for Safari, false for non-existent app")
  func testCanRead() {
#if os(macOS)
    #expect(java.io.File("/Applications/Safari.app").canRead())
    #expect(!java.io.File("/Applications/Internet Explorer.app").canRead())
#endif
  }

  @Test("canWrite returns true for /Users/Shared, false for system app")
  func testCanWrite() {
#if os(macOS)
    #expect(java.io.File("/Users/Shared").canWrite())
    #expect(!java.io.File("/Applications/Safari.app").canWrite())
#endif
  }

  @Test("isDirectory returns true for .app bundle, false for missing path or file")
  func testIsDirectory() {
#if os(macOS)
    #expect(java.io.File("/Applications/Safari.app").isDirectory())
    #expect(!java.io.File("/Applications/!Safari.app").isDirectory())
    #expect(!java.io.File("/Application/Safari.app/Contents/Info.plist").isDirectory())
#endif
  }

  @Test("isHidden returns true for /.file, false for Safari and nonexistent dotfile")
  func testIsHidden() {
#if os(macOS)
    #expect(java.io.File("/.file").isHidden())
    #expect(!java.io.File("/Applications/Safari.app").isHidden())
    #expect(!java.io.File("/.bastie").isHidden())
#endif
  }

  @Test("getAbsolutePath returns path unchanged including . and .. segments")
  func testGetAbsoluteFilePath() {
#if os(macOS)
    #expect(java.io.File("/Applications/Safari.app").getAbsolutePath()                       == "/Applications/Safari.app")
    #expect(java.io.File("/Applications/./Safari.app").getAbsolutePath()                     == "/Applications/./Safari.app")
    #expect(java.io.File("/Applications/../Applications/Safari.app").getAbsolutePath()       == "/Applications/../Applications/Safari.app")
#endif
  }

  /// Regression test against JavApi 0.12.0 bug.
  @Test("listFiles returns entries whose paths all start with the directory path")
  func testListFiles() {
    let dir  = "/Applications"
    let appDir = java.io.File(dir)
    if let apps = appDir.listFiles() {
      for app in apps {
        #expect(app.getAbsolutePath().startsWith(dir))
      }
    }
  }

  /// Regression test against JavApi 0.12.0 bug.
  @Test("listFiles with FileFilter returns only .app directories")
  func testListFilesWithFileFilter() {
    let dir    = "/Applications"
    let appDir = java.io.File(dir)
    if let apps = appDir.listFiles(AppFileFilter()) {
      for app in apps {
        #expect(app.getAbsolutePath().startsWith(dir))
        #expect(app.getAbsolutePath().hasSuffix(".app"))
      }
    }
  }
}

// MARK: - Cross-platform tests

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

// MARK: - Helper types

private class AppFileFilter: java.io.FileFilter {
  func accept(_ file: JavApi.java.io.File) -> Bool {
    file.getName().endsWith(".app") && file.isDirectory()
  }
  typealias FileFilter = AppFileFilter
}
