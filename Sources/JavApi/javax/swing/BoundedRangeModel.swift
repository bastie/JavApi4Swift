/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// The data model for components with a numeric range: `JSlider`,
  /// `JProgressBar`, and `JScrollBar`.
  ///
  /// A `BoundedRangeModel` maintains four related integer properties:
  ///
  /// | Property    | Meaning                                         |
  /// |-------------|-------------------------------------------------|
  /// | `minimum`   | The smallest allowed value                      |
  /// | `maximum`   | The largest allowed value                       |
  /// | `value`     | The current value (`minimum ≤ value`)            |
  /// | `extent`    | The size of the "thumb" (`value+extent ≤ maximum`) |
  ///
  /// The invariant `minimum ≤ value ≤ value+extent ≤ maximum` is always
  /// maintained.
  ///
  /// When `getValueIsAdjusting()` returns `true`, the component is in the
  /// middle of a gesture (e.g. dragging a slider thumb).
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol BoundedRangeModel: AnyObject {

    // -------------------------------------------------------------------------
    // MARK: Accessors — Java-style getters/setters
    // -------------------------------------------------------------------------

    func getMinimum() -> Int
    func setMinimum(_ newMinimum: Int)

    func getMaximum() -> Int
    func setMaximum(_ newMaximum: Int)

    func getValue() -> Int
    func setValue(_ newValue: Int)

    func getExtent() -> Int
    func setExtent(_ newExtent: Int)

    func getValueIsAdjusting() -> Bool
    func setValueIsAdjusting(_ b: Bool)

    /// Sets all four range properties atomically, firing a single `ChangeEvent`.
    func setRangeProperties(value newValue: Int,
                            extent newExtent: Int,
                            minimum newMin: Int,
                            maximum newMax: Int,
                            adjusting b: Bool)

    func addChangeListener(_ l: javax.swing.event.ChangeListener)
    func removeChangeListener(_ l: javax.swing.event.ChangeListener)
  }
}
