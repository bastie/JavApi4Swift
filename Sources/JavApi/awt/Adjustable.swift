/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// The interface for objects which have an adjustable numeric value contained
  /// within a bounded range of values.
  ///
  /// Mirrors `java.awt.Adjustable` (Java 1.1). Implemented for example by
  /// `Scrollbar` and the scrollbars of `ScrollPane`.
  ///
  /// Orientation constants are exposed through the protocol extension below.
  /// Per the JavApi4Swift convention they must be accessed through a concrete
  /// conforming type (e.g. `Scrollbar.HORIZONTAL`), never through the protocol
  /// type itself.
  ///
  /// - Since: JavaApi > 0.20.0 (Java 1.1)
  @MainActor
  public protocol Adjustable {

    /// Gets the orientation of the adjustable object.
    func getOrientation() -> Int

    /// Sets the minimum value of the adjustable object.
    func setMinimum(_ min: Int)
    /// Gets the minimum value of the adjustable object.
    func getMinimum() -> Int

    /// Sets the maximum value of the adjustable object.
    func setMaximum(_ max: Int)
    /// Gets the maximum value of the adjustable object.
    func getMaximum() -> Int

    /// Sets the unit value increment for the adjustable object.
    func setUnitIncrement(_ u: Int)
    /// Gets the unit value increment for the adjustable object.
    func getUnitIncrement() -> Int

    /// Sets the block value increment for the adjustable object.
    func setBlockIncrement(_ b: Int)
    /// Gets the block value increment for the adjustable object.
    func getBlockIncrement() -> Int

    /// Sets the length of the proportional indicator of the adjustable object.
    func setVisibleAmount(_ v: Int)
    /// Gets the length of the proportional indicator.
    func getVisibleAmount() -> Int

    /// Sets the current value of the adjustable object.
    func setValue(_ v: Int)
    /// Gets the current value of the adjustable object.
    func getValue() -> Int

    /// Adds a listener to receive adjustment events from this object.
    func addAdjustmentListener(_ l: java.awt.event.AdjustmentListener)
    /// Removes an adjustment listener from this object.
    func removeAdjustmentListener(_ l: java.awt.event.AdjustmentListener)
  }
}

extension java.awt.Adjustable {

  /// Indicates that the `Adjustable` has horizontal orientation.
  /// - Since: Java 1.1
  nonisolated public static var HORIZONTAL: Int { 0 }

  /// Indicates that the `Adjustable` has vertical orientation.
  /// - Since: Java 1.1
  nonisolated public static var VERTICAL: Int { 1 }

  /// Indicates that the `Adjustable` has no orientation.
  /// - Note: This constant was added in Java 1.4; it is provided here for API
  ///   completeness of the `Adjustable` interface.
  nonisolated public static var NO_ORIENTATION: Int { 2 }
}
