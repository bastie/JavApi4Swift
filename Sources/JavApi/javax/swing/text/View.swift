/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// Abstract base for the rendering views of a text component — mirrors
  /// `javax.swing.text.View` from Java 1.2 / JFC 1.0.
  ///
  /// A `View` maps a region of the document's `Element` tree onto a
  /// graphical area.  The `EditorKit` creates a root `View` for the document;
  /// the root view then creates child views for paragraphs, runs, etc.
  ///
  /// In JavApi⁴Swift, `BasicTextPaneUI` renders the document directly
  /// without a full view hierarchy.  This class is provided for source
  /// compatibility with Java code that references `View`.
  ///
  /// ## Axis constants
  ///
  /// | Constant | Value | Meaning |
  /// |---|---|---|
  /// | `X_AXIS` | 0 | Horizontal layout axis |
  /// | `Y_AXIS` | 1 | Vertical layout axis |
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class View {

    // -------------------------------------------------------------------------
    // MARK: Axis constants
    // -------------------------------------------------------------------------

    public static let X_AXIS: Int = 0
    public static let Y_AXIS: Int = 1

    // -------------------------------------------------------------------------
    // MARK: Break behaviour constants
    // -------------------------------------------------------------------------

    public static let BadBreakWeight:       Int = 0
    public static let GoodBreakWeight:      Int = 1_000
    public static let ExcellentBreakWeight: Int = 2_000
    public static let ForcedBreakWeight:    Int = 3_000

    // -------------------------------------------------------------------------
    // MARK: Element linkage
    // -------------------------------------------------------------------------

    private let _element: javax.swing.text.Element

    /// Returns the document `Element` this view is responsible for.
    public func getElement() -> javax.swing.text.Element { _element }

    /// Returns the start offset of this view's element.
    public func getStartOffset() -> Int { _element.getStartOffset() }

    /// Returns the end offset of this view's element.
    public func getEndOffset() -> Int { _element.getEndOffset() }

    // -------------------------------------------------------------------------
    // MARK: Parent / container
    // -------------------------------------------------------------------------

    private weak var _parent: javax.swing.text.View?

    /// Returns the parent view, or `nil` if this is the root.
    public func getParent() -> javax.swing.text.View? { _parent }

    /// Sets the parent view.
    public func setParent(_ parent: javax.swing.text.View?) { _parent = parent }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ element: javax.swing.text.Element) {
      _element = element
    }

    // -------------------------------------------------------------------------
    // MARK: Painting (to override)
    // -------------------------------------------------------------------------

    /// Renders this view onto `g` within `allocation`.
    ///
    /// Subclasses must override this method.
    open func paint(_ g: java.awt.Graphics, _ allocation: java.awt.Shape) {
      // Default: no-op
    }

    // -------------------------------------------------------------------------
    // MARK: Layout (to override)
    // -------------------------------------------------------------------------

    /// Returns the preferred span along `axis` (`X_AXIS` or `Y_AXIS`).
    open func getPreferredSpan(_ axis: Int) -> Float { 0 }

    /// Returns the minimum span along `axis`.
    open func getMinimumSpan(_ axis: Int) -> Float { getPreferredSpan(axis) }

    /// Returns the maximum span along `axis`.
    open func getMaximumSpan(_ axis: Int) -> Float { getPreferredSpan(axis) }

    // -------------------------------------------------------------------------
    // MARK: Model–view mapping (to override)
    // -------------------------------------------------------------------------

    /// Converts a model offset to a view location.
    open func modelToView(_ pos: Int, _ bias: javax.swing.text.Bias) -> java.awt.Rectangle? { nil }

    /// Converts a view location to a model offset.
    open func viewToModel(_ x: Float, _ y: Float, _ bias: inout javax.swing.text.Bias) -> Int { 0 }
  }
}
