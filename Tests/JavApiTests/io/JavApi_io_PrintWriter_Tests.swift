/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_io_PrintWriter_Tests {

  @Test("PrintWriter(Writer) writes through to the underlying Writer")
  func testPrintWriterFromWriter() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw)
    pw.println("hello")
    #expect(sw.toString().hasPrefix("hello"))
  }

  @Test("PrintWriter(Writer, autoflush: true) flushes after println")
  func testPrintWriterAutoflush() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw, true)
    pw.println("world")
    #expect(sw.toString().hasPrefix("world"))
  }

  @Test("PrintWriter(Writer, autoflush: false) still writes content")
  func testPrintWriterNoAutoflush() throws {
    let sw = java.io.StringWriter()
    let pw = java.io.PrintWriter(sw, false)
    pw.println("test")
    #expect(sw.toString().hasPrefix("test"))
  }
}
