/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  // ---------------------------------------------------------------------------
  // MARK: - LayoutStyle
  // ---------------------------------------------------------------------------

  /// Provides platform-specific gap sizes between components and container edges.
  ///
  /// Mirrors `javax.swing.LayoutStyle`. The class is abstract in Java; here it
  /// is a concrete open class with a default implementation that uses hard-coded
  /// Swing default values (RELATED = 6 px, UNRELATED = 12 px, INDENT = 10 px,
  /// container gap = 10 px).  A custom subclass can be installed via
  /// `setInstance(_:)`.
  ///
  /// ### Usage
  /// ```swift
  /// let style = javax.swing.LayoutStyle.getInstance()
  /// let gap = style.getPreferredGap(
  ///   component1,
  ///   component2,
  ///   type: javax.swing.LayoutStyle.ComponentPlacement.RELATED,
  ///   position: javax.swing.SwingConstants.EAST,
  ///   parent: panel)
  /// ```
  ///
  /// - Since: JavApi > 0.x (Java 6 / Swing)
  @MainActor
  open class LayoutStyle {

    // -------------------------------------------------------------------------
    // MARK: ComponentPlacement
    // -------------------------------------------------------------------------

    /// Describes the visual relationship between two components —
    /// mirrors `javax.swing.LayoutStyle.ComponentPlacement`.
    public enum ComponentPlacement {
      /// Components are related (e.g. a label and its field). Default gap: 6 px.
      case RELATED
      /// Components are unrelated (e.g. two independent groups). Default gap: 12 px.
      case UNRELATED
      /// Component is visually indented below a parent label. Default gap: 10 px.
      case INDENT
    }

    // -------------------------------------------------------------------------
    // MARK: Singleton
    // -------------------------------------------------------------------------

    private static var _instance: LayoutStyle = LayoutStyle()

    /// Returns the shared `LayoutStyle` instance.
    public static func getInstance() -> LayoutStyle {
      _instance
    }

    /// Replaces the shared instance with a custom subclass.
    public static func setInstance(_ style: LayoutStyle) {
      _instance = style
    }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Gap queries
    // -------------------------------------------------------------------------

    /// Returns the preferred gap (in pixels) between two components.
    ///
    /// - Parameters:
    ///   - component1: The leading component (closer to the container edge).
    ///   - component2: The trailing component.
    ///   - type: The visual relationship — `.RELATED`, `.UNRELATED`, or `.INDENT`.
    ///   - position: The side of `component1` that faces `component2`.
    ///               Use `SwingConstants` values: `NORTH`, `SOUTH`, `EAST`, `WEST`.
    ///   - parent: The container both components belong to (may be used by
    ///             subclasses to query look-and-feel defaults).
    /// - Returns: Preferred gap in pixels.
    open func getPreferredGap(
      _ component1: java.awt.Component,
      _ component2: java.awt.Component,
      type: ComponentPlacement,
      position: Int,
      parent: java.awt.Container
    ) -> Int {
      switch type {
      case .RELATED:   return 6
      case .UNRELATED: return 12
      case .INDENT:    return 10
      }
    }

    /// Returns the preferred gap between a component and the container edge.
    ///
    /// - Parameters:
    ///   - component: The component adjacent to the container edge.
    ///   - position: The side of the container. Use `SwingConstants` values.
    ///   - parent: The container.
    /// - Returns: Preferred inset gap in pixels (default: 10 px).
    open func getContainerGap(
      _ component: java.awt.Component,
      position: Int,
      parent: java.awt.Container
    ) -> Int {
      10
    }
  }
}
