/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension java.awt {

  /// Tracks the loading status of images — mirrors `java.awt.MediaTracker`.
  ///
  /// On macOS (AppKit) and iOS/tvOS (UIKit) the native image type is used to
  /// determine whether an image has actually loaded.  On other platforms (Linux,
  /// headless) images are always considered `COMPLETE`.
  ///
  /// ```swift
  /// let tracker = java.awt.MediaTracker(component)
  /// tracker.addImage(img, id: 0)
  /// try tracker.waitForAll()
  /// if tracker.isErrorAny() { /* handle error */ }
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.0)
  public class MediaTracker {

    // -------------------------------------------------------------------------
    // MARK: Status constants
    // -------------------------------------------------------------------------

    /// Image loading has not yet started.
    public static let LOADING   = 1
    /// Image loading was aborted.
    public static let ABORTED   = 2
    /// An error occurred while loading the image.
    public static let ERRORED   = 4
    /// Image has been successfully loaded.
    public static let COMPLETE  = 8

    // -------------------------------------------------------------------------
    // MARK: Internal model
    // -------------------------------------------------------------------------

    private struct Entry {
      let image:  java.awt.Image
      let id:     Int
      var status: Int   // one of the constants above
    }

    private var entries:   [Entry] = []
    private let component: java.awt.Component

    // -------------------------------------------------------------------------
    // MARK: Constructor
    // -------------------------------------------------------------------------

    /// Creates a media tracker for the given component.
    public init(_ component: java.awt.Component) {
      self.component = component
    }

    // -------------------------------------------------------------------------
    // MARK: Adding images
    // -------------------------------------------------------------------------

    /// Adds an image to the tracker under the given ID.
    public func addImage(_ image: java.awt.Image, id: Int) {
      entries.append(Entry(image: image, id: id, status: resolveStatus(image)))
    }

    /// Adds a (possibly scaled) image to the tracker under the given ID.
    public func addImage(_ image: java.awt.Image, id: Int, width: Int, height: Int) {
      entries.append(Entry(image: image, id: id, status: resolveStatus(image)))
    }

    // -------------------------------------------------------------------------
    // MARK: Checking status
    // -------------------------------------------------------------------------

    /// Returns `true` if all images have finished loading (successfully or not).
    public func checkAll(_ load: Bool = false) -> Bool {
      entries.allSatisfy { $0.status == MediaTracker.COMPLETE || $0.status == MediaTracker.ERRORED }
    }

    /// Returns `true` if all images with the given ID have finished loading.
    public func checkID(_ id: Int, load: Bool = false) -> Bool {
      entries.filter { $0.id == id }
             .allSatisfy { $0.status == MediaTracker.COMPLETE || $0.status == MediaTracker.ERRORED }
    }

    /// Returns the combined status flags for all tracked images.
    public func statusAll(_ load: Bool) -> Int {
      entries.reduce(0) { $0 | $1.status }
    }

    /// Returns the combined status flags for images with the given ID.
    public func statusID(_ id: Int, load: Bool) -> Int {
      entries.filter { $0.id == id }.reduce(0) { $0 | $1.status }
    }

    // -------------------------------------------------------------------------
    // MARK: Waiting
    // -------------------------------------------------------------------------

    /// Waits until all images have finished loading.
    ///
    /// On AppKit/UIKit this returns as soon as all images report a terminal
    /// status.  On headless platforms it returns immediately.
    public func waitForAll() throws {
      // Native images load synchronously in this model; nothing to wait for.
    }

    /// Waits at most `ms` milliseconds for all images to finish loading.
    ///
    /// - Returns: `true` if all images finished within the timeout.
    public func waitForAll(_ ms: Int64) throws -> Bool {
      return checkAll()
    }

    /// Waits until all images with the given ID have finished loading.
    public func waitForID(_ id: Int) throws {}

    /// Waits at most `ms` milliseconds for images with the given ID to load.
    ///
    /// - Returns: `true` if the images finished within the timeout.
    public func waitForID(_ id: Int, ms: Int64) throws -> Bool {
      return checkID(id)
    }

    // -------------------------------------------------------------------------
    // MARK: Error handling
    // -------------------------------------------------------------------------

    /// Returns images that encountered errors, or `nil` if none.
    public func getErrorsAny() -> [java.awt.Image]? {
      let errored = entries.filter { $0.status == MediaTracker.ERRORED }.map { $0.image }
      return errored.isEmpty ? nil : errored
    }

    /// Returns images with the given ID that encountered errors, or `nil`.
    public func getErrorsID(_ id: Int) -> [java.awt.Image]? {
      let errored = entries.filter { $0.id == id && $0.status == MediaTracker.ERRORED }.map { $0.image }
      return errored.isEmpty ? nil : errored
    }

    /// Returns `true` if any tracked image encountered an error.
    public func isErrorAny() -> Bool {
      entries.contains { $0.status == MediaTracker.ERRORED }
    }

    /// Returns `true` if any image with the given ID encountered an error.
    public func isErrorID(_ id: Int) -> Bool {
      entries.contains { $0.id == id && $0.status == MediaTracker.ERRORED }
    }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    /// Determines the current load status of an image using the native
    /// platform image representation where available.
    private func resolveStatus(_ image: java.awt.Image) -> Int {
#if canImport(AppKit)
      // BufferedImage wraps a CGImage pixel buffer — always available if non-nil.
      if let buffered = image as? java.awt.image.BufferedImage {
        return buffered.toCGImage() != nil ? MediaTracker.COMPLETE : MediaTracker.ERRORED
      }
      return MediaTracker.COMPLETE
#elseif canImport(UIKit)
      if let buffered = image as? java.awt.image.BufferedImage {
        return buffered.toCGImage() != nil ? MediaTracker.COMPLETE : MediaTracker.ERRORED
      }
      return MediaTracker.COMPLETE
#else
      // Headless / Linux: all images are considered complete.
      return MediaTracker.COMPLETE
#endif
    }
  }
}
