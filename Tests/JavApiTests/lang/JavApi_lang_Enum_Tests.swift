/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// Test-only enum — independent of any production enum to avoid side effects
private enum TestColor: java.lang.Enum {
  public typealias E = TestColor
  case RED
  case GREEN
  case BLUE
}

// MARK: - java.lang.Enum.values()

struct JavApi_lang_Enum_values_Tests {

  @Test("values() returns all cases")
  func testValuesReturnsAllCases() {
    let values = TestColor.RED.values()
    #expect(values.count == 3)
  }

  @Test("values() contains all expected cases")
  func testValuesContainsExpectedCases() {
    let values = TestColor.RED.values()
    #expect(values.contains(.RED))
    #expect(values.contains(.GREEN))
    #expect(values.contains(.BLUE))
  }

  @Test("values() order matches declaration order")
  func testValuesOrder() {
    let values = TestColor.RED.values()
    #expect(values[0] == .RED)
    #expect(values[1] == .GREEN)
    #expect(values[2] == .BLUE)
  }
}

// MARK: - java.lang.Enum.valueOf()

struct JavApi_lang_Enum_valueOf_Tests {

  @Test("valueOf() returns correct case for valid name")
  func testValueOfRed() throws {
    let result = try TestColor.RED.valueOf("RED")
    #expect(result == .RED)
  }

  @Test("valueOf() returns correct case for each value")
  func testValueOfAllCases() throws {
    #expect(try TestColor.RED.valueOf("RED")   == .RED)
    #expect(try TestColor.RED.valueOf("GREEN") == .GREEN)
    #expect(try TestColor.RED.valueOf("BLUE")  == .BLUE)
  }

  @Test("valueOf() throws IllegalArgumentException for unknown name")
  func testValueOfUnknownName() {
    #expect(throws: IllegalArgumentException.self) {
      try TestColor.RED.valueOf("YELLOW")
    }
  }

  @Test("valueOf() exception message contains the invalid name")
  func testValueOfExceptionMessage() {
    do {
      _ = try TestColor.RED.valueOf("YELLOW")
      Issue.record("Expected IllegalArgumentException was not thrown")
    } catch let e as IllegalArgumentException {
      #expect(e.getMessage()?.contains("YELLOW") == true)
    } catch {
      Issue.record("Unexpected error type: \(error)")
    }
  }

  @Test("valueOf() is case-sensitive")
  func testValueOfCaseSensitive() {
    #expect(throws: IllegalArgumentException.self) {
      try TestColor.RED.valueOf("red")
    }
  }
}
