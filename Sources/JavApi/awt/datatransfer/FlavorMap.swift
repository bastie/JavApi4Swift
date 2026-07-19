/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.datatransfer {

  /// Maps between opaque platform-native data-format names and Java
  /// ``DataFlavor``s — mirrors `java.awt.datatransfer.FlavorMap`.
  ///
  /// A "native" is an opaque `String` identifying a platform clipboard/drag
  /// format (e.g. AppKit's `"public.utf8-plain-text"` pasteboard type,
  /// Win32's `"CF_UNICODETEXT"` clipboard format name, or an X11 selection
  /// target atom name such as `"UTF8_STRING"`).
  ///
  /// - Note: This protocol (and ``SystemFlavorMap``) describe the
  ///   native-name ↔ `DataFlavor` lookup table itself. They are **not**
  ///   currently wired into ``Clipboard`` or the platform DnD backends —
  ///   those still talk to the OS pasteboard/clipboard directly through
  ///   their own private bridges (e.g. `_AppKitPasteboardBridge`,
  ///   `_Win32OLEDataObject`, `_X11WindowHost+DnD`). `SystemFlavorMap`'s
  ///   default table uses the same native names those bridges use, so it
  ///   is accurate for introspection/interop even though nothing in this
  ///   module consults it internally yet.
  ///
  /// - Since: Java 1.1 (this port adds it alongside ``SystemFlavorMap``,
  ///   Java 1.2)
  public protocol FlavorMap {

    /// For each flavor in `flavors`, looks up its corresponding native
    /// format name. Flavors with no known native are omitted from the
    /// result.
    func getNativesForFlavors(_ flavors: [DataFlavor]) -> [DataFlavor: String]

    /// For each native format name in `natives`, looks up its corresponding
    /// `DataFlavor`. Natives with no known flavor are omitted from the
    /// result.
    func getFlavorsForNatives(_ natives: [String]) -> [String: DataFlavor]
  }
}
