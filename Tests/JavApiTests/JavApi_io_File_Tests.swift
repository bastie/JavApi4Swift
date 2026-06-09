/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
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

  @Test("isHidden: dot-prefix names are hidden; non-dot names are not")
  func testIsHidden() {
#if os(macOS)
    // /.file exists on macOS and starts with '.' → hidden
    #expect(java.io.File("/.file").isHidden())
    // Safari.app does not start with '.' → not hidden
    #expect(!java.io.File("/Applications/Safari.app").isHidden())
    // /.bastie starts with '.' → hidden (regardless of existence)
    #expect(java.io.File("/.bastie").isHidden())
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

  @Test("temp directory is readable on all platforms")
  func testListFilesOnTmpDir() {
    let tmpDir = java.io.File(FileManager.default.temporaryDirectory.path)
    #expect(tmpDir.isDirectory())
    #expect(tmpDir.listFiles() != nil)
  }
}

// MARK: - Linux-specific tests

struct JavApi_io_File_Linux_Tests {

  // /bin/sh is guaranteed to exist and be executable on any POSIX system
  private let sh = "/bin/sh"
  // /etc/hostname exists and is readable on Linux CI runners
  private let hostname = "/etc/hostname"

  @Test("canExecute returns true for /bin/sh, false for /etc/hostname")
  func testCanExecute() {
#if os(Linux)
    #expect(java.io.File(sh).canExecute())
    #expect(!java.io.File(hostname).canExecute())
#endif
  }

  @Test("canRead returns true for /bin/sh and /etc/hostname")
  func testCanRead() {
#if os(Linux)
    #expect(java.io.File(sh).canRead())
    #expect(java.io.File(hostname).canRead())
#endif
  }

  @Test("canWrite returns true for /tmp, false for non-existent path")
  func testCanWrite() {
#if os(Linux)
    #expect(java.io.File("/tmp").canWrite())
    // A path that never exists is always non-writable, regardless of user privileges
    #expect(!java.io.File("/this_path_does_not_exist_xyz_123").canWrite())
#endif
  }

  @Test("isDirectory returns true for /tmp and /etc, false for /bin/sh")
  func testIsDirectory() {
#if os(Linux)
    #expect(java.io.File("/tmp").isDirectory())
    #expect(java.io.File("/etc").isDirectory())
    #expect(!java.io.File(sh).isDirectory())
#endif
  }

  @Test("isHidden returns true for dot-prefixed names, false otherwise")
  func testIsHidden() {
#if os(Linux)
    // true positive: name starts with '.'
    #expect(java.io.File("/tmp/.hidden_test_file").isHidden())
    #expect(java.io.File("/.dotfile").isHidden())
    // true negative: name does not start with '.'
    #expect(!java.io.File(sh).isHidden())
    #expect(!java.io.File("/tmp").isHidden())
    #expect(!java.io.File("/etc/hostname").isHidden())
#endif
  }

  @Test("getAbsolutePath returns path unchanged")
  func testGetAbsoluteFilePath() {
#if os(Linux)
    #expect(java.io.File(sh).getAbsolutePath()              == sh)
    #expect(java.io.File("/bin/../bin/sh").getAbsolutePath() == "/bin/../bin/sh")
#endif
  }

  @Test("listFiles on /tmp returns entries whose paths start with /tmp")
  func testListFiles() {
#if os(Linux)
    let tmpDir = java.io.File("/tmp")
    if let entries = tmpDir.listFiles() {
      for entry in entries {
        #expect(entry.getAbsolutePath().startsWith("/tmp"))
      }
    }
#endif
  }
}

// MARK: - Helper types

private class AppFileFilter: java.io.FileFilter {
  func accept(_ file: JavApi.java.io.File) -> Bool {
    file.getName().endsWith(".app") && file.isDirectory()
  }
  typealias FileFilter = AppFileFilter
}
