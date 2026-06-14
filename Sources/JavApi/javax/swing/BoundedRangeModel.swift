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
  /// | Property    | Meaning                                     |
  /// |-------------|---------------------------------------------|
  /// | `minimum`   | The smallest allowed value                  |
  /// | `maximum`   | The largest allowed value                   |
  /// | `value`     | The current value (`minimum ≤ value`)        |
  /// | `extent`    | The size of the "thumb" (`value+extent ≤ maximum`) |
  ///
  /// The invariant `minimum ≤ value ≤ value+extent ≤ maximum` is always
  /// maintained; setters clamp values accordingly.
  ///
  /// When `valueIsAdjusting` is `true`, the component is in the middle of
  /// a gesture (e.g. dragging a slider thumb); listeners can use this flag
  /// to defer expensive operations.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol BoundedRangeModel: AnyObject {

    var minimum:          Int  { get set }
    var maximum:          Int  { get set }
    var value:            Int  { get set }
    var extent:           Int  { get set }
    var valueIsAdjusting: Bool { get set }

    /// Sets all four range properties atomically, firing a single `ChangeEvent`.
    func setRangeProperties(value: Int, extent: Int, minimum: Int, maximum: Int, adjusting: Bool)

    func addChangeListener(_ l: javax.swing.event.ChangeListener)
    func removeChangeListener(_ l: javax.swing.event.ChangeListener)
  }
}
