/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK

// =============================================================================
// MARK: Lazy OLE initialisation
// =============================================================================

/// Lazy OLE initialisation for DnD operations.
///
/// `OleInitialize` is only called the first time DnD is actually used
/// (first `RegisterDragDrop` or `DoDragDrop` call).  This avoids the
/// overhead of COM/OLE setup in apps that never perform drag-and-drop.
///
/// - Note: OLE must be initialised on the same thread it will be used on
///   (the main thread in a Win32 AWT app).  `ensureInitialized()` is
///   therefore `@MainActor`.
enum _Win32OLE {

  /// `true` once `OleInitialize` has returned successfully.
  private nonisolated(unsafe) static var _ready = false

  /// Initialises OLE exactly once.  Safe to call repeatedly.
  @MainActor
  static func ensureInitialized() {
    guard !_ready else { return }
    let hr = OleInitialize(nil)
    // S_OK (0) = first init; S_FALSE (1) = already initialised on this thread.
    // Both mean OLE is ready.
    if hr == S_OK || hr == S_FALSE { _ready = true }
  }
}

#endif // os(Windows)
