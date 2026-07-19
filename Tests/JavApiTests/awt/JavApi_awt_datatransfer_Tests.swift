/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

// =============================================================================
// MARK: - DataFlavor
// =============================================================================

@Suite("java.awt.datatransfer.DataFlavor")
struct JavApi_awt_datatransfer_DataFlavor_Tests {

  @Test("stringFlavor has correct MIME type")
  func stringFlavor_mimeType() {
    let f = java.awt.datatransfer.DataFlavor.stringFlavor
    #expect(f.getMimeType() == "application/x-java-serialized-object; class=java.lang.String")
  }

  @Test("plainTextFlavor has correct MIME type")
  @available(*, deprecated) // intentionally tests deprecated plainTextFlavor
  func plainTextFlavor_mimeType() {
    let f = java.awt.datatransfer.DataFlavor.plainTextFlavor
    #expect(f.getMimeType() == "text/plain; charset=unicode")
  }

  @Test("Two flavors with identical MIME types are equal")
  func equality_sameMime() {
    let a = java.awt.datatransfer.DataFlavor(mimeType: "text/plain; charset=unicode",
                                             humanPresentableName: "Plain Text")
    let b = java.awt.datatransfer.DataFlavor(mimeType: "text/plain; charset=unicode",
                                             humanPresentableName: "Other Name")
    #expect(a == b)
  }

  @Test("Two flavors with different MIME types are not equal")
  @available(*, deprecated) // intentionally tests deprecated plainTextFlavor
  func equality_differentMime() {
    let a = java.awt.datatransfer.DataFlavor.stringFlavor
    let b = java.awt.datatransfer.DataFlavor.plainTextFlavor
    #expect(a != b)
  }

  @Test("isMimeTypeEqual returns true for matching base type")
  @available(*, deprecated) // intentionally tests deprecated plainTextFlavor
  func isMimeTypeEqual_match() {
    let f = java.awt.datatransfer.DataFlavor.plainTextFlavor
    #expect(f.isMimeTypeEqual("text/plain; charset=unicode"))
  }

  @Test("isMimeTypeEqual returns false for different type")
  func isMimeTypeEqual_noMatch() {
    let f = java.awt.datatransfer.DataFlavor.stringFlavor
    #expect(!f.isMimeTypeEqual("text/plain"))
  }

  @Test("javaFileListFlavor has correct MIME type")
  func javaFileListFlavor_mimeType() {
    let f = java.awt.datatransfer.DataFlavor.javaFileListFlavor
    #expect(f.getMimeType() == "application/x-java-file-list")
  }

  @Test("javaFileListFlavor is distinct from stringFlavor")
  func javaFileListFlavor_distinct() {
    #expect(java.awt.datatransfer.DataFlavor.javaFileListFlavor !=
            java.awt.datatransfer.DataFlavor.stringFlavor)
  }

  @Test("javaFileListFlavor human-presentable name is set")
  func javaFileListFlavor_humanName() {
    let f = java.awt.datatransfer.DataFlavor.javaFileListFlavor
    #expect(!f.getHumanPresentableName().isEmpty)
  }
}

// =============================================================================
// MARK: - FlavorMap / SystemFlavorMap
// =============================================================================

@Suite("java.awt.datatransfer.SystemFlavorMap")
struct JavApi_awt_datatransfer_SystemFlavorMap_Tests {

  /// The native name this platform's `SystemFlavorMap` seeds for
  /// `stringFlavor` — mirrors the `#if os(...)` table in
  /// `SystemFlavorMap.init()` so this test verifies the actual value
  /// rather than just "some non-nil string".
  private var expectedTextNative: String {
#if canImport(AppKit) && os(macOS)
    return "public.utf8-plain-text"
#elseif os(Windows)
    return "CF_UNICODETEXT"
#elseif os(Linux) || os(FreeBSD)
    return "UTF8_STRING"
#else
    return "text/plain;charset=utf-8"
#endif
  }

  @Test("getDefaultFlavorMap returns the same singleton instance across calls")
  func defaultFlavorMap_isSingleton() {
    // Downcast to the concrete class before comparing identity: casting the
    // non-class-bound `any FlavorMap` existential to `AnyObject` inside
    // `#expect(...)` crashes the Swift 6.3.3 compiler while emitting a
    // reabstraction thunk for the SIL of this test function. Comparing two
    // concretely-typed `SystemFlavorMap?` values with `===` sidesteps that
    // thunk entirely.
    let a = java.awt.datatransfer.SystemFlavorMap.getDefaultFlavorMap()
      as? java.awt.datatransfer.SystemFlavorMap
    let b = java.awt.datatransfer.SystemFlavorMap.getDefaultFlavorMap()
      as? java.awt.datatransfer.SystemFlavorMap
    #expect(a != nil)
    #expect(a === b)
  }

  @Test("stringFlavor resolves to the platform-appropriate native name")
  func stringFlavor_hasPlatformNative() {
    let map = java.awt.datatransfer.SystemFlavorMap()
    let native = map.getNativesForFlavor(java.awt.datatransfer.DataFlavor.stringFlavor)
    #expect(native.first == expectedTextNative)
  }

  @Test("Native name for stringFlavor round-trips back to stringFlavor")
  func stringFlavor_roundTrip() {
    let map = java.awt.datatransfer.SystemFlavorMap()
    let natives = map.getNativesForFlavor(java.awt.datatransfer.DataFlavor.stringFlavor)
    #expect(!natives.isEmpty)
    let flavors = map.getFlavorsForNative(natives[0])
    #expect(flavors.contains(java.awt.datatransfer.DataFlavor.stringFlavor))
  }

  @Test("Unknown flavor has no registered native")
  func unknownFlavor_noNative() {
    let map = java.awt.datatransfer.SystemFlavorMap()
    let custom = java.awt.datatransfer.DataFlavor(mimeType: "application/x-does-not-exist")
    #expect(map.getNativesForFlavor(custom).isEmpty)
  }

  @Test("Unknown native has no registered flavor")
  func unknownNative_noFlavor() {
    let map = java.awt.datatransfer.SystemFlavorMap()
    #expect(map.getFlavorsForNative("no-such-native").isEmpty)
  }

  @Test("getNativesForFlavors / getFlavorsForNatives (bulk FlavorMap API)")
  func bulkLookup() {
    let map: any java.awt.datatransfer.FlavorMap = java.awt.datatransfer.SystemFlavorMap()
    let stringFlavor = java.awt.datatransfer.DataFlavor.stringFlavor
    let natives = map.getNativesForFlavors([stringFlavor])
    #expect(natives[stringFlavor] != nil)

    guard let native = natives[stringFlavor] else { return }
    let flavors = map.getFlavorsForNatives([native])
    #expect(flavors[native] == stringFlavor)
  }

  @Test("addUnencodedNativeForFlavor registers a new native for an existing flavor")
  func addUnencodedNativeForFlavor_registersNative() {
    let map = java.awt.datatransfer.SystemFlavorMap()
    let custom = java.awt.datatransfer.DataFlavor(mimeType: "application/x-custom-test-flavor")
    map.addUnencodedNativeForFlavor(custom, "MY_CUSTOM_NATIVE")
    #expect(map.getNativesForFlavor(custom).contains("MY_CUSTOM_NATIVE"))
    #expect(map.getFlavorsForNative("MY_CUSTOM_NATIVE").contains(custom))
  }

  @Test("addFlavorForUnencodedNative registers a new flavor for an existing native")
  func addFlavorForUnencodedNative_registersFlavor() {
    let map = java.awt.datatransfer.SystemFlavorMap()
    let custom = java.awt.datatransfer.DataFlavor(mimeType: "application/x-another-custom-flavor")
    map.addFlavorForUnencodedNative("ANOTHER_NATIVE", custom)
    #expect(map.getFlavorsForNative("ANOTHER_NATIVE").contains(custom))
    #expect(map.getNativesForFlavor(custom).contains("ANOTHER_NATIVE"))
  }

  @Test("Newly-added instances are independent from the shared default map")
  func freshInstance_isIndependentFromDefault() {
    let fresh = java.awt.datatransfer.SystemFlavorMap()
    let custom = java.awt.datatransfer.DataFlavor(mimeType: "application/x-isolated-test-flavor")
    fresh.addUnencodedNativeForFlavor(custom, "ISOLATED_NATIVE")

    let shared = java.awt.datatransfer.SystemFlavorMap.getDefaultFlavorMap()
    #expect(shared.getNativesForFlavors([custom]).isEmpty)
  }
}

// =============================================================================
// MARK: - StringSelection
// =============================================================================

@Suite("java.awt.datatransfer.StringSelection")
struct JavApi_awt_datatransfer_StringSelection_Tests {

  @Test("StringSelection supports stringFlavor")
  func supportsStringFlavor() {
    let s = java.awt.datatransfer.StringSelection("hello")
    #expect(s.isDataFlavorSupported(java.awt.datatransfer.DataFlavor.stringFlavor))
  }

  @Test("StringSelection does not support plainTextFlavor (deprecated)")
  @available(*, deprecated) // intentionally tests deprecated plainTextFlavor
  func doesNotSupportPlainTextFlavor() {
    let s = java.awt.datatransfer.StringSelection("hello")
    #expect(!s.isDataFlavorSupported(java.awt.datatransfer.DataFlavor.plainTextFlavor))
  }

  @Test("getTransferDataFlavors returns exactly stringFlavor")
  func getTransferDataFlavors_count() {
    let s = java.awt.datatransfer.StringSelection("hello")
    let flavors = s.getTransferDataFlavors()
    #expect(flavors.count == 1)
    #expect(flavors[0] == java.awt.datatransfer.DataFlavor.stringFlavor)
  }

  @Test("getTransferData returns the original string")
  func getTransferData_returnsString() throws {
    let s = java.awt.datatransfer.StringSelection("world")
    let data = try s.getTransferData(java.awt.datatransfer.DataFlavor.stringFlavor)
    #expect(data as? String == "world")
  }

  @Test("getTransferData throws UnsupportedFlavorException for wrong flavor")
  @available(*, deprecated) // intentionally tests deprecated plainTextFlavor
  func getTransferData_wrongFlavor_throws() {
    let s = java.awt.datatransfer.StringSelection("x")
    #expect(throws: (any Error).self) {
      try s.getTransferData(java.awt.datatransfer.DataFlavor.plainTextFlavor)
    }
  }
}

// =============================================================================
// MARK: - HeadlessClipboardProvider (unit — no OS dependency)
// =============================================================================

@Suite("java.awt.toolkit._HeadlessClipboardProvider")
struct JavApi_awt_datatransfer_HeadlessProvider_Tests {

  @Test("Initially returns nil")
  func initiallyNil() {
    let p = java.awt.toolkit.headless._HeadlessClipboardProvider()
    #expect(p._getClipboardText() == nil)
  }

  @Test("Round-trip: set then get returns same string")
  func roundTrip() {
    let p = java.awt.toolkit.headless._HeadlessClipboardProvider()
    p._setClipboardText("Hallo Welt")
    #expect(p._getClipboardText() == "Hallo Welt")
  }

  @Test("Overwrite: last written value wins")
  func overwrite() {
    let p = java.awt.toolkit.headless._HeadlessClipboardProvider()
    p._setClipboardText("first")
    p._setClipboardText("second")
    #expect(p._getClipboardText() == "second")
  }

  @Test("Empty string is stored (not nil)")
  func emptyString() {
    let p = java.awt.toolkit.headless._HeadlessClipboardProvider()
    p._setClipboardText("")
    #expect(p._getClipboardText() == "")
  }

  @Test("Unicode including emoji round-trips correctly")
  func unicodeRoundTrip() {
    let p = java.awt.toolkit.headless._HeadlessClipboardProvider()
    let s = "こんにちは 🌸 Ü ñ"
    p._setClipboardText(s)
    #expect(p._getClipboardText() == s)
  }
}

// =============================================================================
// MARK: - Clipboard API (via HeadlessClipboardProvider)
// =============================================================================

@Suite("java.awt.datatransfer.Clipboard (headless)")
struct JavApi_awt_datatransfer_Clipboard_Tests {

  /// Helper: builds a Clipboard backed by the in-memory provider.
  private func makeClipboard() -> java.awt.datatransfer.Clipboard {
    let p = java.awt.toolkit.headless._HeadlessClipboardProvider()
    return java.awt.datatransfer.Clipboard(name: "test", provider: p)
  }

  @Test("getName returns constructor argument")
  func getName() {
    let c = makeClipboard()
    #expect(c.getName() == "test")
  }

  @Test("getContents returns nil before any setContents")
  func getContents_initially_nil() {
    let c = makeClipboard()
    #expect(c.getContents(nil) == nil)
  }

  @Test("setContents then getContents returns same Transferable")
  func setContents_getContents_roundTrip() throws {
    let c = makeClipboard()
    let sel = java.awt.datatransfer.StringSelection("clipboard test")
    c.setContents(sel, nil)
    let result = c.getContents(nil)
    let data = try result?.getTransferData(java.awt.datatransfer.DataFlavor.stringFlavor)
    #expect(data as? String == "clipboard test")
  }

  @Test("setContents notifies previous owner via lostOwnership")
  func setContents_notifiesPreviousOwner() {
    class OwnerSpy: java.awt.datatransfer.ClipboardOwner {
      var called = false
      func lostOwnership(_ clipboard: java.awt.datatransfer.Clipboard,
                         _ contents: any java.awt.datatransfer.Transferable) {
        called = true
      }
    }

    let c = makeClipboard()
    let spy = OwnerSpy()
    let first  = java.awt.datatransfer.StringSelection("first")
    let second = java.awt.datatransfer.StringSelection("second")
    c.setContents(first, spy)
    // spy is not notified yet — it still owns the clipboard
    #expect(!spy.called)
    // replacing with second selection must notify spy
    c.setContents(second, nil)
    #expect(spy.called)
  }

  @Test("setContents persists text to underlying provider")
  func setContents_persistsToProvider() {
    let provider = java.awt.toolkit.headless._HeadlessClipboardProvider()
    let c = java.awt.datatransfer.Clipboard(name: "p", provider: provider)
    c.setContents(java.awt.datatransfer.StringSelection("persist"), nil)
    // read directly from the provider to verify persistence
    #expect(provider._getClipboardText() == "persist")
  }

  @Test("getContents falls back to provider text when no in-process Transferable")
  func getContents_fallsBackToProvider() throws {
    let provider = java.awt.toolkit.headless._HeadlessClipboardProvider()
    provider._setClipboardText("from provider")
    let c = java.awt.datatransfer.Clipboard(name: "p", provider: provider)
    // no setContents called — clipboard has no in-process Transferable
    let result = c.getContents(nil)
    let data = try result?.getTransferData(java.awt.datatransfer.DataFlavor.stringFlavor)
    #expect(data as? String == "from provider")
  }
}

// =============================================================================
// MARK: - Platform-specific provider integration tests
//
// These tests call the real OS clipboard.  They run on macOS (AppKit),
// iOS/tvOS (UIKit), Linux / FreeBSD (X11 / Wayland), and Windows (GDI).
// On WASI / CI without a display they fall back to HeadlessClipboardProvider,
// which is already tested above.
//
// Tests in this suite are marked `.serialized` because parallel writes to the
// OS clipboard would race.
// =============================================================================

@Suite("java.awt.toolkit — platform clipboard provider (integration)",
       .serialized)
struct JavApi_awt_datatransfer_PlatformProvider_Tests {

  /// The provider returned by the default toolkit for this platform.
  private func provider() -> any java.awt.toolkit.ClipboardProvider {
    // SwiftUIToolkit / GDIToolkit / X11Toolkit — whichever is default —
    // is not available in the test target, so we instantiate directly:
#if canImport(AppKit)
    return java.awt.toolkit._AppKitClipboardProvider()
#elseif canImport(UIKit) && !os(watchOS)
    return java.awt.toolkit._UIKitClipboardProvider()
#elseif os(Windows)
    return java.awt.toolkit._Win32ClipboardProvider()
#elseif os(Linux) || os(FreeBSD)
    return java.awt.toolkit._X11ClipboardProvider()
#else
    return java.awt.toolkit._HeadlessClipboardProvider()
#endif
  }

  @Test("Platform provider round-trip: write then read")
  func platformRoundTrip() {
    let p = provider()
    let sentinel = "JavApi4Swift-test-\(Int.random(in: 0..<1_000_000))"
    p._setClipboardText(sentinel)
    let result = p._getClipboardText()
    #expect(result == sentinel)
  }

  @Test("Platform provider handles multiline text")
  func platformMultiline() {
    let p = provider()
    let text = "line1\nline2\nline3"
    p._setClipboardText(text)
    #expect(p._getClipboardText() == text)
  }

  @Test("Platform provider handles non-ASCII / Unicode")
  func platformUnicode() {
    let p = provider()
    let text = "Ü ñ 日本語 🎉"
    p._setClipboardText(text)
    #expect(p._getClipboardText() == text)
  }

  @Test("Overwrite: platform provider returns last value")
  func platformOverwrite() {
    let p = provider()
    p._setClipboardText("alpha")
    p._setClipboardText("beta")
    #expect(p._getClipboardText() == "beta")
  }
}
