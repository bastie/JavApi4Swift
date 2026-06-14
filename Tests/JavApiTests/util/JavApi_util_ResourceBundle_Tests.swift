/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Tests for java.util.ResourceBundle, ListResourceBundle,
/// PropertyResourceBundle and MissingResourceException.
struct JavApi_util_ResourceBundle_Tests {

  // MARK: - ListResourceBundle

  @Test("ListResourceBundle returns String value for known key")
  func testListBundleGetString() throws {
    let bundle = TestBundle()
    let value = try bundle.getString("greeting")
    #expect(value == "Hello")
  }

  @Test("ListResourceBundle returns String array for known key")
  func testListBundleGetStringArray() throws {
    let bundle = TestBundle()
    let arr = try bundle.getStringArray("colors")
    #expect(arr == ["red", "green", "blue"])
  }

  @Test("ListResourceBundle containsKey returns true for existing key")
  func testListBundleContainsKey() {
    let bundle = TestBundle()
    #expect(bundle.containsKey("greeting") == true)
    #expect(bundle.containsKey("unknown") == false)
  }

  @Test("ListResourceBundle keySet contains all keys")
  func testListBundleKeySet() {
    let bundle = TestBundle()
    let keys = bundle.keySet()
    #expect(keys.contains("greeting"))
    #expect(keys.contains("farewell"))
    #expect(keys.contains("colors"))
  }

  @Test("ListResourceBundle throws MissingResourceException for unknown key")
  func testListBundleMissingKey() throws {
    let bundle = TestBundle()
    #expect(throws: java.util.MissingResourceException.self) {
      _ = try bundle.getObject("nonexistent")
    }
  }

  // MARK: - Parent chain

  @Test("Parent chain: child overrides key, missing key falls through to parent")
  func testParentChain() throws {
    let parent = TestBundle()
    let child  = ChildBundle()
    child.parent = parent

    // child defines "greeting" → should return child's value
    let greeting = try child.getString("greeting")
    #expect(greeting == "Hi")

    // "farewell" not in child → falls through to parent
    let farewell = try child.getString("farewell")
    #expect(farewell == "Goodbye")
  }

  // MARK: - PropertyResourceBundle

  @Test("PropertyResourceBundle loads key=value pairs from text")
  func testPropertyBundleLoad() throws {
    let bundle = java.util.PropertyResourceBundle()
    bundle.loadFromText("""
      # comment
      host=localhost
      port=8080
      """)
    #expect((try bundle.getString("host")) == "localhost")
    #expect((try bundle.getString("port")) == "8080")
  }

  @Test("PropertyResourceBundle falls through to parent for missing key")
  func testPropertyBundleParentFallthrough() throws {
    let parent = java.util.PropertyResourceBundle()
    parent.loadFromText("key=fromParent")
    let child = java.util.PropertyResourceBundle()
    child.parent = parent

    let value = try child.getString("key")
    #expect(value == "fromParent")
  }

  // MARK: - MissingResourceException

  @Test("MissingResourceException stores className and key")
  func testMissingResourceException() {
    let ex = java.util.MissingResourceException("msg", "MyBundle", "myKey")
    #expect(ex.getClassName() == "MyBundle")
    #expect(ex.getKey() == "myKey")
  }
}

// MARK: - Helpers

private final class TestBundle: java.util.ListResourceBundle {
  override func getContents() -> [(String, Any)] {
    return [
      ("greeting", "Hello"),
      ("farewell", "Goodbye"),
      ("colors",   ["red", "green", "blue"]),
    ]
  }
}

private final class ChildBundle: java.util.ListResourceBundle {
  override func getContents() -> [(String, Any)] {
    return [
      ("greeting", "Hi"),
    ]
  }
}
