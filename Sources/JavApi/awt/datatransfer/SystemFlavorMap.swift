/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.awt.datatransfer {

  /// The platform default ``FlavorMap`` — mirrors
  /// `java.awt.datatransfer.SystemFlavorMap`.
  ///
  /// Ships pre-seeded with native-name mappings for the well-known flavors
  /// declared on ``DataFlavor`` (`stringFlavor`, `plainTextFlavor`,
  /// `javaFileListFlavor`), using the same native format names the
  /// platform-specific DnD/clipboard bridges use, chosen at compile time:
  ///
  /// | Platform          | text native          | file-list native  |
  /// |-------------------|-----------------------|--------------------|
  /// | Apple (AppKit)    | `public.utf8-plain-text` | `public.file-url` |
  /// | Windows (Win32)   | `CF_UNICODETEXT`      | `CF_HDROP`         |
  /// | X11 (Linux/FreeBSD) | `UTF8_STRING`       | `text/uri-list`    |
  /// | other (WASM, headless, …) | `text/plain;charset=utf-8` | `text/uri-list` |
  ///
  /// Additional mappings can be registered at runtime via
  /// ``addFlavorForUnencodedNative(_:_:)`` / ``addUnencodedNativeForFlavor(_:_:)``.
  ///
  /// All mutable state is guarded by an `NSLock`, mirroring the pattern
  /// used by `java.util.logging.LogManager` — `SystemFlavorMap` is a
  /// process-wide singleton (``getDefaultFlavorMap()``) and Swift Testing
  /// runs tests concurrently, so unsynchronised dictionary access would be
  /// a data race.
  ///
  /// - Since: Java 1.2 (`getNativesForFlavor`/`getFlavorsForNative`/
  ///   `addFlavorForUnencodedNative`/`addUnencodedNativeForFlavor` are
  ///   technically Java 1.4 `FlavorTable` additions, folded in here for
  ///   usability rather than tracked as a separate 1.4 entry — the same
  ///   pragmatic version-blending already used elsewhere in this port,
  ///   e.g. `Path2D`).
  public final class SystemFlavorMap: FlavorMap, @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: - Singleton
    // -------------------------------------------------------------------------

    nonisolated(unsafe) private static let _instance = SystemFlavorMap()

    /// Returns the platform default flavor map (a shared singleton).
    public static func getDefaultFlavorMap() -> any FlavorMap {
      _instance
    }

    // -------------------------------------------------------------------------
    // MARK: - State
    // -------------------------------------------------------------------------

    private let lock = NSLock()
    private var nativesForFlavor: [DataFlavor: [String]] = [:]
    private var flavorsForNative: [String: [DataFlavor]] = [:]

    private func withLock<T>(_ body: () -> T) -> T {
      lock.lock()
      defer { lock.unlock() }
      return body()
    }

    // -------------------------------------------------------------------------
    // MARK: - Init
    // -------------------------------------------------------------------------

    /// Internal so tests/callers go through ``getDefaultFlavorMap()``
    /// (matching Java, where `SystemFlavorMap`'s constructor is package-private)
    /// while still allowing a fresh, independently-seeded instance to be
    /// constructed for tests that want isolation from the shared singleton.
    internal init() {
      #if canImport(AppKit) && os(macOS)
      registerUnlocked(DataFlavor.stringFlavor, native: "public.utf8-plain-text")
      registerUnlocked(DataFlavor.javaFileListFlavor, native: "public.file-url")
      #elseif os(Windows)
      registerUnlocked(DataFlavor.stringFlavor, native: "CF_UNICODETEXT")
      registerUnlocked(DataFlavor.javaFileListFlavor, native: "CF_HDROP")
      #elseif os(Linux) || os(FreeBSD)
      registerUnlocked(DataFlavor.stringFlavor, native: "UTF8_STRING")
      registerUnlocked(DataFlavor.javaFileListFlavor, native: "text/uri-list")
      #else
      registerUnlocked(DataFlavor.stringFlavor, native: "text/plain;charset=utf-8")
      registerUnlocked(DataFlavor.javaFileListFlavor, native: "text/uri-list")
      #endif
      // plainTextFlavor is deprecated in favour of stringFlavor; give it the
      // same native as stringFlavor so lookups still succeed for old callers.
      // Registered non-primary (appended, not prepended) so stringFlavor —
      // not the deprecated plainTextFlavor — stays the native's primary
      // (first) flavor in getFlavorsForNative(s)/getFlavorsForNatives.
      if let textNative = nativesForFlavor[DataFlavor.stringFlavor]?.first {
        registerUnlocked(DataFlavor.plainTextFlavor, native: textNative, primary: false)
      }
    }

    /// Registers `native` for `flavor`.
    ///
    /// - Parameter primary: when `true` (the default), `native`/`flavor`
    ///   are prepended, becoming the "primary" entry returned by
    ///   ``getNativesForFlavors(_:)``/``getFlavorsForNatives(_:)`` (used by
    ///   ordinary registrations, including runtime `addUnencodedNativeForFlavor`/
    ///   `addFlavorForUnencodedNative` calls, so newer registrations win).
    ///   Pass `false` to append instead — used for the deprecated
    ///   `plainTextFlavor` auto-registration in `init()`, so it doesn't
    ///   steal primacy from `stringFlavor` for the same native.
    private func registerUnlocked(_ flavor: DataFlavor, native: String, primary: Bool = true) {
      var natives = nativesForFlavor[flavor] ?? []
      if !natives.contains(native) {
        if primary { natives.insert(native, at: 0) } else { natives.append(native) }
      }
      nativesForFlavor[flavor] = natives
      var flavors = flavorsForNative[native] ?? []
      if !flavors.contains(flavor) {
        if primary { flavors.insert(flavor, at: 0) } else { flavors.append(flavor) }
      }
      flavorsForNative[native] = flavors
    }

    // -------------------------------------------------------------------------
    // MARK: - FlavorMap
    // -------------------------------------------------------------------------

    public func getNativesForFlavors(_ flavors: [DataFlavor]) -> [DataFlavor: String] {
      withLock {
        var result: [DataFlavor: String] = [:]
        for flavor in flavors {
          if let native = nativesForFlavor[flavor]?.first { result[flavor] = native }
        }
        return result
      }
    }

    public func getFlavorsForNatives(_ natives: [String]) -> [String: DataFlavor] {
      withLock {
        var result: [String: DataFlavor] = [:]
        for native in natives {
          if let first = flavorsForNative[native]?.first { result[native] = first }
        }
        return result
      }
    }

    // -------------------------------------------------------------------------
    // MARK: - Convenience single-item lookups (Java 1.4 FlavorTable API)
    // -------------------------------------------------------------------------

    /// Returns every native format name registered for `flavor`, most
    /// recently added first — empty if none are known.
    public func getNativesForFlavor(_ flavor: DataFlavor) -> [String] {
      withLock { nativesForFlavor[flavor] ?? [] }
    }

    /// Returns every `DataFlavor` registered for `native`, most recently
    /// added first — empty if none are known.
    public func getFlavorsForNative(_ native: String) -> [DataFlavor] {
      withLock { flavorsForNative[native] ?? [] }
    }

    // -------------------------------------------------------------------------
    // MARK: - Mutation
    // -------------------------------------------------------------------------

    /// Registers `native` as an additional native format name for `flavor`.
    public func addUnencodedNativeForFlavor(_ flavor: DataFlavor, _ native: String) {
      withLock { registerUnlocked(flavor, native: native) }
    }

    /// Registers `flavor` as an additional `DataFlavor` for `native`.
    public func addFlavorForUnencodedNative(_ native: String, _ flavor: DataFlavor) {
      withLock { registerUnlocked(flavor, native: native) }
    }
  }
}
