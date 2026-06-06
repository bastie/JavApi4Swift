/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Basisklasse für alle nativen Fenster — mirrors `java.awt.Window`.
  ///
  /// `Window` sitzt in der Hierarchie zwischen `Container` und `Frame`:
  ///
  ///   Component → Container → **Window** → Frame
  ///
  /// Verantwortlichkeiten:
  /// - Sichtbarkeit (`setVisible`, `isVisible`)
  /// - Lebenszyklus-Dispatch (WindowListener: opened, closing, closed …)
  /// - Toolkit-Anbindung (show/hide)
  /// - `pack()` — layoutet und dimensioniert das Fenster auf preferred size
  /// - `dispose()` — schließt und gibt Ressourcen frei
  /// - `toFront()` / `toBack()` — Fensterstapel (Stub, plattformabhängig)
  @MainActor
  open class Window: Container {

    // -------------------------------------------------------------------------
    // MARK: Sichtbarkeit
    // -------------------------------------------------------------------------

    /// Macht das Fenster sichtbar oder versteckt es.
    open override func setVisible(_ visible: Bool) {
      let wasVisible = self.visible
      self.visible   = visible
      let toolkit    = java.awt.Toolkit.getDefaultToolkit()
      if visible {
        toolkit.show(self)
        if !wasVisible {
          fireWindowEvent(java.awt.event.WindowEvent.WINDOW_OPENED)
        }
        fireWindowEvent(java.awt.event.WindowEvent.WINDOW_ACTIVATED)
      } else {
        fireWindowEvent(java.awt.event.WindowEvent.WINDOW_DEACTIVATED)
        fireWindowEvent(java.awt.event.WindowEvent.WINDOW_CLOSING)
        toolkit.hide(self)
        fireWindowEvent(java.awt.event.WindowEvent.WINDOW_CLOSED)
      }
    }

    public override func isVisible() -> Bool { visible }

    // -------------------------------------------------------------------------
    // MARK: Lebenszyklus
    // -------------------------------------------------------------------------

    /// Schließt das Fenster und gibt Ressourcen frei.
    open func dispose() {
      setVisible(false)
    }

    /// Layoutet alle Kinder und passt die Fenstergröße auf `preferredSize` an.
    open func pack() {
      validate()
      // Minimale Implementierung: Fenstergröße = bevorzugte Größe des Inhalts
      let ps = getPreferredSize()
      if ps.width > 0 && ps.height > 0 {
        bounds = java.awt.Rectangle(bounds.x, bounds.y, ps.width, ps.height)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Fensterstapel
    // -------------------------------------------------------------------------

    /// Bringt das Fenster in den Vordergrund (plattformabhängig; Stub).
    open func toFront() {}

    /// Schickt das Fenster in den Hintergrund (plattformabhängig; Stub).
    open func toBack() {}

    // -------------------------------------------------------------------------
    // MARK: WindowEvent-Dispatch
    // -------------------------------------------------------------------------

    private func fireWindowEvent(_ id: Int) {
      let e = java.awt.event.WindowEvent(self, id)
      processWindowEvent(e)
    }

    // -------------------------------------------------------------------------
    // MARK: SwiftUI-Identität
    // -------------------------------------------------------------------------

    /// Stabile ID für SwiftUI `ForEach` — basiert auf Objektidentität.
    public var objectID: ObjectIdentifier { ObjectIdentifier(self) }
  }
}
