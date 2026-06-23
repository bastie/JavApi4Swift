/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Boolean.booleanValue()

struct JavApi_lang_Boolean_booleanValue_Tests {

  @Test("booleanValue() returns true for true")
  func testBooleanValueTrue() {
    let b: Boolean = true
    #expect(b.boolValue() == true)
  }

  @Test("booleanValue() returns false for false")
  func testBooleanValueFalse() {
    let b: Boolean = false
    #expect(b.boolValue() == false)
  }
}

// MARK: - Boolean.equals()

struct JavApi_lang_Boolean_equals_Tests {

  @Test("equals() true == true")
  func testEqualsTrueTrue() {
    let b: Boolean = true
    #expect(b.equals(true) == true)
  }

  @Test("equals() false == false")
  func testEqualsFalseFalse() {
    let b: Boolean = false
    #expect(b.equals(false) == true)
  }

  @Test("equals() true != false")
  func testEqualsTrueFalse() {
    let b: Boolean = true
    #expect(b.equals(false) == false)
  }

  @Test("equals() nil returns false")
  func testEqualsNil() {
    let b: Boolean = true
    #expect(b.equals(nil) == false)
  }

  @Test("equals() non-Bool type returns false")
  func testEqualsWrongType() {
    let b: Boolean = true
    #expect(b.equals("true") == false)
    #expect(b.equals(1) == false)
  }
}

// MARK: - Boolean.hashcode()

struct JavApi_lang_Boolean_hashcode_Tests {

  @Test("hashcode() for true and false differ")
  func testHashcodeDiffer() {
    let t: Boolean = true
    let f: Boolean = false
    #expect(t.hashcode() != f.hashcode())
  }

  @Test("hashcode() is stable (same value same result)")
  func testHashcodeStable() {
    let b: Boolean = true
    #expect(b.hashcode() == b.hashcode())
  }
}

// MARK: - Boolean.toString()

struct JavApi_lang_Boolean_toString_Tests {

  @Test("toString() of true returns \"true\"")
  func testToStringTrue() {
    let b: Boolean = true
    #expect(b.toString() == "true")
  }

  @Test("toString() of false returns \"false\"")
  func testToStringFalse() {
    let b: Boolean = false
    #expect(b.toString() == "false")
  }
}

// MARK: - Boolean.valueOf()

struct JavApi_lang_Boolean_valueOf_Tests {

  @Test("valueOf(\"true\") returns true (case insensitive)")
  func testValueOfTrue() {
    #expect(Boolean.valueOf("true") == true)
    #expect(Boolean.valueOf("TRUE") == true)
    #expect(Boolean.valueOf("True") == true)
    #expect(Boolean.valueOf("tRuE") == true)
  }

  @Test("valueOf(\"false\") returns false")
  func testValueOfFalse() {
    #expect(Boolean.valueOf("false") == false)
    #expect(Boolean.valueOf("FALSE") == false)
  }

  @Test("valueOf(nil) returns false")
  func testValueOfNil() {
    #expect(Boolean.valueOf(nil) == false)
  }

  @Test("valueOf(\"\") returns false")
  func testValueOfEmpty() {
    #expect(Boolean.valueOf("") == false)
  }

  @Test("valueOf(\"yes\") returns false — only \"true\" is truthy")
  func testValueOfYes() {
    #expect(Boolean.valueOf("yes") == false)
    #expect(Boolean.valueOf("1") == false)
    #expect(Boolean.valueOf("on") == false)
  }
}

// MARK: - Boolean init(String?)
//
// Java: new Boolean("TRUE") → true  (case-insensitive since Java 1.0)
// JavApi: Boolean.init(_ value: String?) implements this.
//
// Swift/Java interop limitation:
//   Boolean is a typealias for Bool. Swift's built-in Bool.init?(_ description: String)
//   is failable and case-sensitive. Writing Boolean("TRUE") directly is ambiguous —
//   Swift resolves it to the built-in and returns nil instead of true.
//   Tests therefore pass an explicit String? to unambiguously invoke the JavApi init.
//   Use valueOf() as the idiomatic, ambiguity-free Java API.

struct JavApi_lang_Boolean_init_Tests {

  @Test("init(String?) with \"true\" creates true")
  func testInitTrue() {
    let s: String? = "true"
    #expect(Boolean(s) == true)
  }

  @Test("init(String?) with \"TRUE\" creates true (case insensitive)")
  func testInitTrueUpperCase() {
    let s: String? = "TRUE"
    #expect(Boolean(s) == true)
  }

  @Test("init(String?) with \"True\" creates true (case insensitive)")
  func testInitTrueMixedCase() {
    let s: String? = "True"
    #expect(Boolean(s) == true)
  }

  @Test("init(String?) with \"false\" creates false")
  func testInitFalse() {
    let s: String? = "false"
    #expect(Boolean(s) == false)
  }

  @Test("init(String?) with nil creates false")
  func testInitNil() {
    let s: String? = nil
    #expect(Boolean(s) == false)
  }

  @Test("init(String?) with \"yes\" creates false — only \"true\" is truthy")
  func testInitYes() {
    let s: String? = "yes"
    #expect(Boolean(s) == false)
  }
}

// MARK: - Boolean.getBoolean() — Java 1.1 default (case insensitive)

struct JavApi_lang_Boolean_getBoolean_Java11_Tests {

  @Test("getBoolean() returns false if property not set")
  func testGetBooleanNotSet() throws {
    try System.clearProperty("test.javapi.bool.notset")
    #expect(Boolean.getBoolean("test.javapi.bool.notset") == false)
  }

  @Test("getBoolean() returns true for lowercase \"true\" property value")
  func testGetBooleanLowercase() throws {
    try System.setProperty("test.javapi.bool.lower", "true")
    #expect(Boolean.getBoolean("test.javapi.bool.lower") == true)
    try System.clearProperty("test.javapi.bool.lower")
  }

  @Test("getBoolean() returns true for uppercase \"TRUE\" (Java 1.1 case-insensitive)")
  func testGetBooleanUppercase() throws {
    try System.setProperty("test.javapi.bool.upper", "TRUE")
    #expect(Boolean.getBoolean("test.javapi.bool.upper") == true)
    try System.clearProperty("test.javapi.bool.upper")
  }

  @Test("getBoolean() returns true for mixed-case \"True\" (Java 1.1 case-insensitive)")
  func testGetBooleanMixedCase() throws {
    try System.setProperty("test.javapi.bool.mixed", "True")
    #expect(Boolean.getBoolean("test.javapi.bool.mixed") == true)
    try System.clearProperty("test.javapi.bool.mixed")
  }

  @Test("getBoolean() returns false for \"false\" property value")
  func testGetBooleanFalseValue() throws {
    try System.setProperty("test.javapi.bool.falseval", "false")
    #expect(Boolean.getBoolean("test.javapi.bool.falseval") == false)
    try System.clearProperty("test.javapi.bool.falseval")
  }

  @Test("getBoolean() returns false for \"yes\" — only \"true\" is truthy")
  func testGetBooleanYes() throws {
    try System.setProperty("test.javapi.bool.yes", "yes")
    #expect(Boolean.getBoolean("test.javapi.bool.yes") == false)
    try System.clearProperty("test.javapi.bool.yes")
  }

  @Test("getBoolean(nil) returns false")
  func testGetBooleanNilKey() {
    #expect(Boolean.getBoolean(nil) == false)
  }
}

// MARK: - Boolean.getBoolean() — Java 1.0 via `for:` parameter (case sensitive)

struct JavApi_lang_Boolean_getBoolean_Java10_Tests {

  @Test("getBoolean(for:\"1.0\") returns true only for exact lowercase \"true\"")
  func testGetBooleanJava10Lowercase() throws {
    try System.setProperty("test.javapi.bool10.lower", "true")
    #expect(Boolean.getBoolean("test.javapi.bool10.lower", for: "1.0") == true)
    try System.clearProperty("test.javapi.bool10.lower")
  }

  @Test("getBoolean(for:\"1.0\") returns false for uppercase \"TRUE\" (case-sensitive)")
  func testGetBooleanJava10Uppercase() throws {
    try System.setProperty("test.javapi.bool10.upper", "TRUE")
    #expect(Boolean.getBoolean("test.javapi.bool10.upper", for: "1.0") == false)
    try System.clearProperty("test.javapi.bool10.upper")
  }

  @Test("getBoolean(for:\"1.0\") returns false for mixed-case \"True\" (case-sensitive)")
  func testGetBooleanJava10MixedCase() throws {
    try System.setProperty("test.javapi.bool10.mixed", "True")
    #expect(Boolean.getBoolean("test.javapi.bool10.mixed", for: "1.0") == false)
    try System.clearProperty("test.javapi.bool10.mixed")
  }
}

// MARK: - Boolean.getBoolean() — via java.expected.version System Property
//
// These tests mutate the global java.expected.version property, so they must
// not run in parallel with each other or with other property-sensitive tests.
// .serialized keeps them in the same suite and prevents interleaving.

@Suite(.serialized)
struct JavApi_lang_Boolean_getBoolean_expectedVersion_Tests {

  @Test("java.expected.version=1.0 makes getBoolean() case-sensitive")
  func testExpectedVersion10CaseSensitive() throws {
    let previousVersion = System.getProperty("java.expected.version", "\(Int.max)")
    defer {
      // always restore, even if the test throws
      _ = try? System.setProperty("java.expected.version", previousVersion)
      _ = try? System.clearProperty("test.javapi.bool.expver")
    }
    try System.setProperty("java.expected.version", "1.0")
    try System.setProperty("test.javapi.bool.expver", "TRUE")

    // for: "undefined" → runtime picks java.expected.version == "1.0" → case-sensitive
    #expect(Boolean.getBoolean("test.javapi.bool.expver") == false)
  }

  @Test("java.expected.version != 1.0 makes getBoolean() case-insensitive")
  func testExpectedVersion11CaseInsensitive() throws {
    let previousVersion = System.getProperty("java.expected.version", "\(Int.max)")
    defer {
      _ = try? System.setProperty("java.expected.version", previousVersion)
      _ = try? System.clearProperty("test.javapi.bool.expver11")
    }
    try System.setProperty("java.expected.version", "1.1")
    try System.setProperty("test.javapi.bool.expver11", "TRUE")

    #expect(Boolean.getBoolean("test.javapi.bool.expver11") == true)
  }
}
