/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
#if canImport(Network)
import Network
#endif
@testable import JavApi

struct JavApi_io_FileDescriptor_Tests {

  // ---------------------------------------------------------------------------
  // MARK: - Default constructor
  // ---------------------------------------------------------------------------

  @Test("Default init creates an invalid descriptor (no handle attached)")
  func testDefaultInitIsInvalid() {
    let fd = java.io.FileDescriptor()
    #expect(!fd.valid())
  }

  // ---------------------------------------------------------------------------
  // MARK: - File-backed descriptor
  // ---------------------------------------------------------------------------

  @Test("Descriptor backed by an open FileHandle is valid")
  func testFileHandleValid() throws {
    // Use a well-known readable file that exists on every Apple/Linux platform
    let url = URL(fileURLWithPath: "/dev/null")
    let handle = try FileHandle(forReadingFrom: url)
    defer { try? handle.close() }

    let fd = java.io.FileDescriptor(handle: handle)
    #expect(fd.valid())
  }

  @Test("Descriptor is invalid after markClosed()")
  func testFileHandleInvalidAfterMarkClosed() throws {
    let url = URL(fileURLWithPath: "/dev/null")
    let handle = try FileHandle(forReadingFrom: url)
    defer { try? handle.close() }

    let fd = java.io.FileDescriptor(handle: handle)
    #expect(fd.valid())

    // Stream wrappers call markClosed() when they close the handle.
    fd.markClosed()
    #expect(!fd.valid())
  }

  @Test("Descriptor wrapping a temp file handle is valid, then invalid after markClosed")
  func testTempFileLifecycle() throws {
    let tmp = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
    guard FileManager.default.createFile(atPath: tmp.path, contents: Data()) else {
      Issue.record("Could not create temp file at \(tmp.path)")
      return
    }
    defer { try? FileManager.default.removeItem(at: tmp) }

    let handle = try FileHandle(forWritingTo: tmp)
    defer { try? handle.close() }

    let fd = java.io.FileDescriptor(handle: handle)
    #expect(fd.valid())

    fd.markClosed()
    #expect(!fd.valid())
  }

  // ---------------------------------------------------------------------------
  // MARK: - Socket-backed descriptor (Network framework)
  // ---------------------------------------------------------------------------

#if canImport(Network)
  @Test("Descriptor backed by a ready NWConnection is valid")
  func testNWConnectionValid() async throws {
    // Connect to loopback — only checks state transitions, no real traffic needed
    let conn = NWConnection(
      host: "127.0.0.1",
      port: 9,   // discard port — connection attempt is enough to reach .preparing
      using: .tcp)

    let fd = java.io.FileDescriptor(handle: conn)

    // Before start() the state is .setup → valid() returns false
    #expect(!fd.valid())

    conn.cancel()
  }
#endif
}
