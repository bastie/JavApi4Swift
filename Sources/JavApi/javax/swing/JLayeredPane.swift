/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A container that manages its children in named Z-order layers.
  ///
  /// `JLayeredPane` divides its depth into a set of named layers.  Components
  /// in higher-numbered layers are painted on top of components in lower-numbered
  /// layers.  Within a single layer, components are ordered by their position in
  /// the children array.
  ///
  /// ## Standard layers (low → high)
  ///
  /// | Constant | Value | Typical use |
  /// |---|---|---|
  /// | `DEFAULT_LAYER` | 0 | Normal components |
  /// | `PALETTE_LAYER` | 100 | Floating toolbars |
  /// | `MODAL_LAYER` | 200 | Modal dialog blocking layers |
  /// | `POPUP_LAYER` | 300 | Pop-up menus, tool tips |
  /// | `DRAG_LAYER` | 400 | Components being dragged |
  ///
  /// Inside `JRootPane`, the content pane sits in `DEFAULT_LAYER` and the menu
  /// bar in `FRAME_CONTENT_LAYER` (a reserved negative value).
  ///
  /// - Note: This is a clean-room stub.  Layer-aware painting and per-component
  ///   layer assignment will be added when `JRootPane` painting is implemented.
  @MainActor
  open class JLayeredPane: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Layer constants
    // -------------------------------------------------------------------------

    public static let DEFAULT_LAYER:      Int = 0
    public static let PALETTE_LAYER:      Int = 100
    public static let MODAL_LAYER:        Int = 200
    public static let POPUP_LAYER:        Int = 300
    public static let DRAG_LAYER:         Int = 400
    public static let FRAME_CONTENT_LAYER: Int = -30000

    public override init() {
      super.init()
      // JLayeredPane manages Z-order manually — no layout manager needed.
      setLayout(nil)
    }

    // -------------------------------------------------------------------------
    // MARK: Layer map
    // -------------------------------------------------------------------------

    /// Maps ObjectIdentifier → layer number for each child component.
    private var layerMap: [ObjectIdentifier: Int] = [:]

    // -------------------------------------------------------------------------
    // MARK: Layer assignment
    // -------------------------------------------------------------------------

    /// Adds `component` to the specified layer.
    ///
    /// Components in higher-numbered layers are painted last (on top).
    /// Within the same layer, later-added components are on top.
    public func add(_ component: java.awt.Component, layer: Int) {
      layerMap[ObjectIdentifier(component)] = layer
      add(component)   // appends to AWT children list
    }

    /// Returns the layer number for `component`, or `DEFAULT_LAYER` if unknown.
    public func getLayer(_ component: java.awt.Component) -> Int {
      layerMap[ObjectIdentifier(component)] ?? JLayeredPane.DEFAULT_LAYER
    }

    /// Moves `component` to `layer`.
    public func setLayer(_ component: java.awt.Component, layer: Int) {
      layerMap[ObjectIdentifier(component)] = layer
    }

    // -------------------------------------------------------------------------
    // MARK: Layer-aware remove
    // -------------------------------------------------------------------------

    public override func remove(_ comp: java.awt.Component) {
      layerMap.removeValue(forKey: ObjectIdentifier(comp))
      super.remove(comp)
    }

    // -------------------------------------------------------------------------
    // MARK: Layer-ordered painting
    // -------------------------------------------------------------------------

    /// Paints children in ascending layer order (lowest layer first → painted below).
    /// Within the same layer the order from the children array is preserved
    /// (bringToFront moves a frame to the end → painted last → on top).
    override open func paintChildren(_ g: java.awt.Graphics) {
      // Sort by layer ascending; within the same layer children-array order is
      // preserved (index 0 = bottom, last index = top / drawn last).
      // bringToFront() moves a component to children[last] so it is drawn on top.
      let sorted = children.sorted {
        let la = layerMap[ObjectIdentifier($0)] ?? JLayeredPane.DEFAULT_LAYER
        let lb = layerMap[ObjectIdentifier($1)] ?? JLayeredPane.DEFAULT_LAYER
        if la != lb { return la < lb }
        // same layer: preserve children-array order (stable sort would do this
        // automatically, but Swift's sort IS stable, so this branch is redundant
        // but left here for clarity)
        return false
      }
      for child in sorted where child.visible {
        let dx = child.bounds.x
        let dy = child.bounds.y
        g.save()
        g.clipRect(dx, dy, child.bounds.width, child.bounds.height)
        g.translate(dx, dy)
        child.paint(g)
        g.restore()
      }
    }
  }
}
