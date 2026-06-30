/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Represents a component's ability to accept dropped data —
  /// mirrors `java.awt.dnd.DropTarget`.
  ///
  /// In headless mode all operations are no-ops.
  ///
  /// - Since: Java 1.2
  open class DropTarget {

    /// The component this target is registered on.
    private weak var _component: java.awt.Component?

    /// The registered listener.
    private var listener: (any DropTargetListener)?

    /// The accepted drop actions.
    private var actions: Int

    /// Whether this target is active.
    private var active: Bool

    /// The context (lazily created).
    private lazy var _context: DropTargetContext = DropTargetContext(dropTarget: self)

    // ── Initialisers ──────────────────────────────────────────────────────────

    /// Creates a `DropTarget` with no component or listener.
    public init() {
      self.actions = DnDConstants.ACTION_COPY_OR_MOVE
      self.active = true
    }

    /// Creates a `DropTarget` attached to a component.
    public init(_ component: java.awt.Component,
                actions: Int = DnDConstants.ACTION_COPY_OR_MOVE,
                listener: (any DropTargetListener)? = nil,
                active: Bool = true) {
      self._component = component
      self.actions = actions
      self.listener = listener
      self.active = active
    }

    // ── API ───────────────────────────────────────────────────────────────────

    /// Returns the component associated with this target.
    public func getComponent() -> java.awt.Component? { _component }

    /// Sets the component (no-op in headless mode).
    public func setComponent(_ c: java.awt.Component) { _component = c }

    /// Returns the accepted drop actions.
    public func getDefaultActions() -> Int { actions }

    /// Sets the accepted drop actions.
    public func setDefaultActions(_ ops: Int) { actions = ops }

    /// Whether this target is currently active.
    public func isActive() -> Bool { active }

    /// Activates or deactivates this target.
    public func setActive(_ isActive: Bool) { active = isActive }

    /// Adds a drop-target listener.
    public func addDropTargetListener(_ dtl: any DropTargetListener) {
      listener = dtl
    }

    /// Removes the drop-target listener.
    public func removeDropTargetListener(_ dtl: any DropTargetListener) {
      if let l = listener, ObjectIdentifier(l) == ObjectIdentifier(dtl) {
        listener = nil
      }
    }

    /// Returns the `DropTargetContext` for this target.
    public func getDropTargetContext() -> DropTargetContext { _context }
  }
}
