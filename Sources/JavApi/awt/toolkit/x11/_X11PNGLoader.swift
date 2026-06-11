/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)

// =============================================================================
// MARK: _X11PNGLoader
// =============================================================================

/// Minimal PNG loader for Linux / FreeBSD.
///
/// Mirrors `_PNGLoader` from the GDI backend.
/// TODO: Implement a full PNG decoder (zlib inflate + IHDR/IDAT parsing).
///       The GDI backend's `_PNGLoader.swift` is a pure-Swift implementation
///       that can be shared or moved to a platform-independent location.
enum _X11PNGLoader {

  /// Attempts to load a PNG file at `path` and returns a `BufferedImage`.
  ///
  /// Currently returns `nil` — replace with actual PNG decoding.
  static func load(path: String) -> java.awt.image.BufferedImage? {
    // TODO: Read file bytes, verify PNG signature, decode IHDR/IDAT chunks,
    //       inflate with zlib (available via Glibc's libz: zlibVersion()),
    //       and construct a BufferedImage from the decoded RGBA pixel data.
    return nil
  }
}
#endif
