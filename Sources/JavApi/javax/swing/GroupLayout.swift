/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  // ---------------------------------------------------------------------------
  // MARK: - GroupLayout
  // ---------------------------------------------------------------------------

  /// Lays out components using two independent group hierarchies — one for the
  /// horizontal axis, one for the vertical axis — mirrors `javax.swing.GroupLayout`.
  ///
  /// ### Concept
  ///
  /// You define two independent group trees:
  /// - **Horizontal group**: determines each component's x-position and width.
  /// - **Vertical group**: determines each component's y-position and height.
  ///
  /// Each group is either *sequential* (children placed one after another) or
  /// *parallel* (children share the same start position and the group size is
  /// the maximum of all children).
  ///
  /// ```swift
  /// let layout = javax.swing.GroupLayout(panel)
  /// panel.setLayout(layout)
  ///
  /// // Horizontal: label | gap | field
  /// layout.setHorizontalGroup(
  ///   layout.createSequentialGroup()
  ///     .addComponent(label)
  ///     .addGap(8)
  ///     .addComponent(field)
  /// )
  ///
  /// // Vertical: label and field aligned on the same baseline row
  /// layout.setVerticalGroup(
  ///   layout.createParallelGroup()
  ///     .addComponent(label)
  ///     .addComponent(field)
  /// )
  /// ```
  ///
  /// > **AI hint:** Every component must appear in **both** the horizontal and
  /// > the vertical group tree exactly once.  Missing a component in one axis
  /// > causes it to render with size 0 on that axis.
  ///
  /// - Since: JavApi > 0.x (Java 6 / Swing)
  @MainActor
  public final class GroupLayout: java.awt.LayoutManager2 {

    // -------------------------------------------------------------------------
    // MARK: Alignment constants
    // -------------------------------------------------------------------------

    public static let LEADING   = 0
    public static let TRAILING  = 1
    public static let CENTER    = 2
    public static let BASELINE  = 3

    /// Sentinel for "use component preferred / min / max size".
    public static let DEFAULT_SIZE: Int = -1
    /// Sentinel for "use component preferred size".
    public static let PREFERRED_SIZE: Int = -2

    // -------------------------------------------------------------------------
    // MARK: Group base class
    // -------------------------------------------------------------------------

    /// Abstract base for `SequentialGroup` and `ParallelGroup`.
    @MainActor
    public class Group {

      // Each element is either a component, a fixed gap, or a nested group.
      enum Element {
        case component(java.awt.Component, min: Int, pref: Int, max: Int)
        case gap(min: Int, pref: Int, max: Int)
        case group(Group)
      }

      var elements: [Element] = []

      // -- Fluent API ----------------------------------------------------------

      @discardableResult
      public func addComponent(_ comp: java.awt.Component) -> Group {
        elements.append(.component(comp,
          min:  GroupLayout.DEFAULT_SIZE,
          pref: GroupLayout.DEFAULT_SIZE,
          max:  GroupLayout.DEFAULT_SIZE))
        return self
      }

      @discardableResult
      public func addComponent(
        _ comp: java.awt.Component,
        _ min: Int, _ pref: Int, _ max: Int
      ) -> Group {
        elements.append(.component(comp, min: min, pref: pref, max: max))
        return self
      }

      @discardableResult
      public func addGap(_ size: Int) -> Group {
        elements.append(.gap(min: size, pref: size, max: size))
        return self
      }

      @discardableResult
      public func addGap(_ min: Int, _ pref: Int, _ max: Int) -> Group {
        elements.append(.gap(min: min, pref: pref, max: max))
        return self
      }

      @discardableResult
      public func addGroup(_ group: Group) -> Group {
        elements.append(.group(group))
        return self
      }

      // -- Size queries (overridden by subclasses) ------------------------------

      /// Preferred size along this group's axis given available `space`.
      func preferredSize(
        axis: Axis,
        availableSpace: Int,
        compPref: (java.awt.Component) -> Int
      ) -> Int { 0 }

      /// Lay out elements: assign each component its (origin, size) on this axis.
      func layout(
        axis: Axis,
        origin: Int,
        size: Int,
        compPref: (java.awt.Component) -> Int,
        assign: (java.awt.Component, Int, Int) -> Void
      ) {}
    }

    // -------------------------------------------------------------------------
    // MARK: SequentialGroup
    // -------------------------------------------------------------------------

    /// Places children one after another along the axis.
    @MainActor
    public final class SequentialGroup: Group {

      override func preferredSize(
        axis: Axis,
        availableSpace: Int,
        compPref: (java.awt.Component) -> Int
      ) -> Int {
        elements.reduce(0) { sum, el in
          switch el {
          case .component(let c, _, _, _):
            return sum + compPref(c)
          case .gap(_, let p, _):
            return sum + p
          case .group(let g):
            return sum + g.preferredSize(axis: axis, availableSpace: availableSpace, compPref: compPref)
          }
        }
      }

      override func layout(
        axis: Axis,
        origin: Int,
        size: Int,
        compPref: (java.awt.Component) -> Int,
        assign: (java.awt.Component, Int, Int) -> Void
      ) {
        var cursor = origin
        for el in elements {
          switch el {
          case .component(let c, _, let explicitPref, _):
            let pref = explicitPref == GroupLayout.DEFAULT_SIZE || explicitPref == GroupLayout.PREFERRED_SIZE
                       ? compPref(c) : explicitPref
            assign(c, cursor, pref)
            cursor += pref
          case .gap(_, let p, _):
            cursor += p
          case .group(let g):
            let gPref = g.preferredSize(axis: axis, availableSpace: size, compPref: compPref)
            g.layout(axis: axis, origin: cursor, size: gPref, compPref: compPref, assign: assign)
            cursor += gPref
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: ParallelGroup
    // -------------------------------------------------------------------------

    /// All children share the same start position; the group size is the maximum.
    @MainActor
    public final class ParallelGroup: Group {

      private let alignment: Int

      init(alignment: Int = GroupLayout.LEADING) {
        self.alignment = alignment
      }

      override func preferredSize(
        axis: Axis,
        availableSpace: Int,
        compPref: (java.awt.Component) -> Int
      ) -> Int {
        elements.reduce(0) { maxSoFar, el in
          switch el {
          case .component(let c, _, _, _):
            return Swift.max(maxSoFar, compPref(c))
          case .gap(_, let p, _):
            return Swift.max(maxSoFar, p)
          case .group(let g):
            return Swift.max(maxSoFar, g.preferredSize(axis: axis, availableSpace: availableSpace, compPref: compPref))
          }
        }
      }

      override func layout(
        axis: Axis,
        origin: Int,
        size: Int,
        compPref: (java.awt.Component) -> Int,
        assign: (java.awt.Component, Int, Int) -> Void
      ) {
        for el in elements {
          switch el {
          case .component(let c, _, let explicitPref, _):
            let pref = explicitPref == GroupLayout.DEFAULT_SIZE || explicitPref == GroupLayout.PREFERRED_SIZE
                       ? compPref(c) : explicitPref
            // For LEADING align at origin; for TRAILING pin to the end.
            let start: Int
            switch alignment {
            case GroupLayout.TRAILING:
              start = origin + size - pref
            case GroupLayout.CENTER:
              start = origin + (size - pref) / 2
            default: // LEADING / BASELINE
              start = origin
            }
            // In a ParallelGroup, stretch component to fill the group on this
            // axis if it is smaller — matches Java's default LEADING behaviour
            // for vertical groups.
            assign(c, start, size)
          case .gap:
            break   // gaps inside a ParallelGroup have no effect on placement
          case .group(let g):
            g.layout(axis: axis, origin: origin, size: size, compPref: compPref, assign: assign)
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Axis helper
    // -------------------------------------------------------------------------

    enum Axis { case horizontal, vertical }

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private weak var host: java.awt.Container?
    private var horizontalGroup: Group?
    private var verticalGroup:   Group?

    // Resolved layout values: component → (origin, size) per axis
    private var hLayout: [ObjectIdentifier: (origin: Int, size: Int)] = [:]
    private var vLayout: [ObjectIdentifier: (origin: Int, size: Int)] = [:]

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ host: java.awt.Container) {
      self.host = host
    }

    // -------------------------------------------------------------------------
    // MARK: Group factories
    // -------------------------------------------------------------------------

    public func createSequentialGroup() -> SequentialGroup {
      SequentialGroup()
    }

    public func createParallelGroup() -> ParallelGroup {
      ParallelGroup(alignment: GroupLayout.LEADING)
    }

    public func createParallelGroup(_ alignment: Int) -> ParallelGroup {
      ParallelGroup(alignment: alignment)
    }

    // -------------------------------------------------------------------------
    // MARK: Group assignment
    // -------------------------------------------------------------------------

    public func setHorizontalGroup(_ group: Group) {
      horizontalGroup = group
    }

    public func setVerticalGroup(_ group: Group) {
      verticalGroup = group
    }

    // -------------------------------------------------------------------------
    // MARK: LayoutManager
    // -------------------------------------------------------------------------

    public func addLayoutComponent(_ name: String, _ comp: java.awt.Component) {}
    public func removeLayoutComponent(_ comp: java.awt.Component) {
      hLayout.removeValue(forKey: ObjectIdentifier(comp))
      vLayout.removeValue(forKey: ObjectIdentifier(comp))
    }

    public func preferredLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      let w = horizontalGroup?.preferredSize(
        axis: .horizontal,
        availableSpace: parent.bounds.width,
        compPref: { $0.getPreferredSize().width }) ?? 0
      let h = verticalGroup?.preferredSize(
        axis: .vertical,
        availableSpace: parent.bounds.height,
        compPref: { $0.getPreferredSize().height }) ?? 0
      return java.awt.Dimension(w, h)
    }

    public func minimumLayoutSize(_ parent: java.awt.Container) -> java.awt.Dimension {
      java.awt.Dimension(0, 0)
    }

    public func layoutContainer(_ parent: java.awt.Container) {
      hLayout.removeAll()
      vLayout.removeAll()

      let containerW = parent.bounds.width
      let containerH = parent.bounds.height

      // Resolve horizontal axis
      horizontalGroup?.layout(
        axis: .horizontal,
        origin: 0,
        size: containerW,
        compPref: { $0.getPreferredSize().width }
      ) { comp, origin, size in
        self.hLayout[ObjectIdentifier(comp)] = (origin, size)
      }

      // Resolve vertical axis
      verticalGroup?.layout(
        axis: .vertical,
        origin: 0,
        size: containerH,
        compPref: { $0.getPreferredSize().height }
      ) { comp, origin, size in
        self.vLayout[ObjectIdentifier(comp)] = (origin, size)
      }

      // Apply bounds to each component
      for child in parent.getComponents() {
        let id = ObjectIdentifier(child)
        let h  = hLayout[id] ?? (0, child.getPreferredSize().width)
        let v  = vLayout[id] ?? (0, child.getPreferredSize().height)
        child.bounds = java.awt.Rectangle(h.origin, v.origin, h.size, v.size)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: LayoutManager2
    // -------------------------------------------------------------------------

    public func addLayoutComponent(_ comp: java.awt.Component, _ constraints: AnyObject?) {}

    public func maximumLayoutSize(_ target: java.awt.Container) -> java.awt.Dimension {
      java.awt.Dimension(Int.max, Int.max)
    }

    public func getLayoutAlignmentX(_ target: java.awt.Container) -> Double { 0.5 }
    public func getLayoutAlignmentY(_ target: java.awt.Container) -> Double { 0.5 }

    public func invalidateLayout(_ target: java.awt.Container) {
      hLayout.removeAll()
      vLayout.removeAll()
    }
  }
}
