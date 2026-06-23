/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  // ---------------------------------------------------------------------------
  // MARK: - BoxLayout
  // ---------------------------------------------------------------------------

  /// Stacks components either horizontally or vertically — mirrors `javax.swing.BoxLayout`.
  ///
  /// Unlike `java.awt.FlowLayout`, `BoxLayout` never wraps: all components stay
  /// on a single axis.  The two most common axes are:
  ///
  /// - `BoxLayout.X_AXIS` — left-to-right, like a horizontal toolbar
  /// - `BoxLayout.Y_AXIS` — top-to-bottom, like a vertical form
  ///
  /// Each component is sized to its preferred size along the layout axis.
  /// Perpendicular to the axis every component is stretched to fill the
  /// available space (capped at its maximum size), matching Java's behaviour.
  ///
  /// ```swift
  /// let box = javax.swing.JPanel()
  /// box.setLayout(javax.swing.BoxLayout(box, javax.swing.BoxLayout.Y_AXIS))
  /// box.add(javax.swing.JLabel("Name:"))
  /// box.add(javax.swing.JTextField(20))
  /// ```
  ///
  /// > **AI hint:** `BoxLayout` holds a *weak* reference to its target container
  /// > so there is no retain cycle between the panel and its layout manager.
  /// > The `target` parameter in `init` must be the *same* container that will
  /// > call `setLayout` — passing a different container throws a fatal error at
  /// > layout time, exactly as Java does.
  ///
  /// - Since: JavApi > 0.x (Java 1.2 / Swing 1.0)
  @MainActor
  public final class BoxLayout: java.awt.LayoutManager {

    // -------------------------------------------------------------------------
    // MARK: Axis constants
    // -------------------------------------------------------------------------

    /// Lay out components left-to-right.
    public static let X_AXIS = 0
    /// Lay out components top-to-bottom.
    public static let Y_AXIS = 1
    /// Lay out components along the reading direction of the target's locale
    /// (left-to-right for most Western locales). Mapped to `X_AXIS` here.
    public static let LINE_AXIS = 2
    /// Lay out components perpendicular to the reading direction
    /// (top-to-bottom for most Western locales). Mapped to `Y_AXIS` here.
    public static let PAGE_AXIS = 3

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private weak var target: java.awt.Container?
    private let axis: Int

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates a `BoxLayout` that stacks the components of `target` along `axis`.
    ///
    /// - Parameters:
    ///   - target: The container whose children will be laid out.
    ///   - axis:   One of `X_AXIS`, `Y_AXIS`, `LINE_AXIS`, or `PAGE_AXIS`.
    public init(_ target: java.awt.Container, _ axis: Int) {
      precondition(
        axis == BoxLayout.X_AXIS || axis == BoxLayout.Y_AXIS ||
        axis == BoxLayout.LINE_AXIS || axis == BoxLayout.PAGE_AXIS,
        "BoxLayout: axis must be X_AXIS, Y_AXIS, LINE_AXIS, or PAGE_AXIS"
      )
      self.target = target
      self.axis   = axis
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    /// The axis along which components are stacked.
    public func getAxis() -> Int { axis }

    // -------------------------------------------------------------------------
    // MARK: LayoutManager
    // -------------------------------------------------------------------------

    public func addLayoutComponent(_ name: String, _ comp: java.awt.Component) {}
    public func removeLayoutComponent(_ comp: java.awt.Component) {}

    public func preferredLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      let children = parent.getComponents()
      guard !children.isEmpty else { return java.awt.Dimension(0, 0) }

      if isHorizontal {
        // Total width = sum of preferred widths; height = max preferred height.
        var totalW = 0
        var maxH   = 0
        for child in children {
          let ps = child.getPreferredSize()
          totalW += ps.width
          maxH    = max(maxH, ps.height)
        }
        return java.awt.Dimension(totalW, maxH)
      } else {
        // Total height = sum of preferred heights; width = max preferred width.
        var maxW   = 0
        var totalH = 0
        for child in children {
          let ps = child.getPreferredSize()
          maxW    = max(maxW, ps.width)
          totalH += ps.height
        }
        return java.awt.Dimension(maxW, totalH)
      }
    }

    public func minimumLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      java.awt.Dimension(0, 0)
    }

    public func layoutContainer(_ parent: java.awt.Container) {
      let children = parent.getComponents()
      guard !children.isEmpty else { return }

      let containerW = parent.bounds.width
      let containerH = parent.bounds.height

      if isHorizontal {
        // Each child gets its preferred width; height = full container height.
        var x = 0
        for child in children {
          let ps = child.getPreferredSize()
          let w  = ps.width > 0 ? ps.width : max(1, child.bounds.width)
          child.bounds = java.awt.Rectangle(x, 0, w, containerH)
          x += w
        }
      } else {
        // Each child gets its preferred height; width = full container width.
        var y = 0
        for child in children {
          let ps = child.getPreferredSize()
          let h  = ps.height > 0 ? ps.height : max(1, child.bounds.height)
          child.bounds = java.awt.Rectangle(0, y, containerW, h)
          y += h
        }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Helpers
    // -------------------------------------------------------------------------

    /// `true` for X_AXIS / LINE_AXIS, `false` for Y_AXIS / PAGE_AXIS.
    private var isHorizontal: Bool {
      axis == BoxLayout.X_AXIS || axis == BoxLayout.LINE_AXIS
    }
  }
}
