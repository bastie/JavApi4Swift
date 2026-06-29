/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// =============================================================================
// MARK: - BufferedImage : WritableRenderedImage
// =============================================================================

/// Makes `BufferedImage` conform to `WritableRenderedImage` (and by inheritance
/// to `RenderedImage`), matching the Java specification.
///
/// `BufferedImage` is a single-tile image, so all tile methods delegate to the
/// full-image raster. The observer list is managed here; actual writability
/// notifications are fired from `getWritableTile` / `releaseWritableTile`.
extension java.awt.image.BufferedImage: java.awt.image.WritableRenderedImage {

  // -------------------------------------------------------------------------
  // MARK: RenderedImage
  // -------------------------------------------------------------------------

  public func getSampleModel() -> java.awt.image.SampleModel {
    getRaster().sampleModel
  }

  // getColorModel(), getData() already exist on BufferedImage.
  // RenderedImage requires no-argument getWidth/getHeight; satisfy explicitly:
  public func getWidth()  -> Int { width }
  public func getHeight() -> Int { height }

  // -------------------------------------------------------------------------
  // MARK: WritableRenderedImage — tile management
  // -------------------------------------------------------------------------

  /// Returns the single tile of this image as a `WritableRaster`.
  ///
  /// Fires `tileUpdate(_:_:_:_:)` on all registered observers the first time
  /// the tile is checked out.
  public func getWritableTile(_ tileX: Int, _ tileY: Int) -> java.awt.image.WritableRaster {
    guard tileX == 0, tileY == 0 else {
      fatalError("BufferedImage has only one tile at (0,0)")
    }
    let wasWritable = _writableTileCount > 0
    _writableTileCount += 1
    if !wasWritable {
      for obs in _tileObservers { obs.tileUpdate(self, 0, 0, true) }
    }
    return getRaster()
  }

  /// Releases the write lock on the single tile.
  public func releaseWritableTile(_ tileX: Int, _ tileY: Int) {
    guard tileX == 0, tileY == 0 else { return }
    if _writableTileCount > 0 {
      _writableTileCount -= 1
      if _writableTileCount == 0 {
        for obs in _tileObservers { obs.tileUpdate(self, 0, 0, false) }
      }
    }
  }

  public func isTileWritable(_ tileX: Int, _ tileY: Int) -> Bool {
    tileX == 0 && tileY == 0 && _writableTileCount > 0
  }

  public func getWritableTileIndices() -> [[Int]]? {
    _writableTileCount > 0 ? [[0, 0]] : nil
  }

  public func hasTileWriters() -> Bool { _writableTileCount > 0 }

  // -------------------------------------------------------------------------
  // MARK: WritableRenderedImage — observers
  // -------------------------------------------------------------------------

  public func addTileObserver(_ to: any java.awt.image.TileObserver) {
    _tileObservers.append(to)
  }

  public func removeTileObserver(_ to: any java.awt.image.TileObserver) {
    _tileObservers.removeAll { $0 === to }
  }
}

// =============================================================================
// MARK: - Stored properties via associated-object workaround
// =============================================================================

// Swift does not allow stored properties in protocol extensions or retroactive
// class extensions. We use a private wrapper stored via Objective-C associated
// objects on Apple platforms, and a global dictionary on Linux/Windows.

import Foundation

private final class _BufferedImageState {
  var writableTileCount: Int = 0
  var tileObservers: [any java.awt.image.TileObserver] = []
}

// Key for associated object (address used as key pointer)
nonisolated(unsafe) private var _stateKey: UInt8 = 0

private func state(of image: java.awt.image.BufferedImage) -> _BufferedImageState {
#if canImport(ObjectiveC)
  if let existing = objc_getAssociatedObject(image, &_stateKey) as? _BufferedImageState {
    return existing
  }
  let s = _BufferedImageState()
  objc_setAssociatedObject(image, &_stateKey, s, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  return s
#else
  // Fallback: global dictionary keyed by ObjectIdentifier
  return _globalState(for: image)
#endif
}

#if !canImport(ObjectiveC)
import Foundation
nonisolated(unsafe) private var _globalStates: [ObjectIdentifier: _BufferedImageState] = [:]
private func _globalState(for image: java.awt.image.BufferedImage) -> _BufferedImageState {
  let id = ObjectIdentifier(image)
  if let s = _globalStates[id] { return s }
  let s = _BufferedImageState()
  _globalStates[id] = s
  return s
}
#endif

extension java.awt.image.BufferedImage {
  fileprivate var _writableTileCount: Int {
    get { state(of: self).writableTileCount }
    set { state(of: self).writableTileCount = newValue }
  }
  fileprivate var _tileObservers: [any java.awt.image.TileObserver] {
    get { state(of: self).tileObservers }
    set { state(of: self).tileObservers = newValue }
  }
}
