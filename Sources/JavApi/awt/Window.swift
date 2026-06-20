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
    
    /// - Returns: Returns a Window specific locale if set or the system defautl Locale
    /// - Since: Java 1.1
    open override func getLocale() -> java.util.Locale {
      if let myLocale = _componentLocale {
        return myLocale
      }
      return java.util.Locale.getDefault()
    }

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
        toolkit.hide(self)
        fireWindowEvent(java.awt.event.WindowEvent.WINDOW_CLOSED)
      }
    }

    public override func isVisible() -> Bool { visible }

    // -------------------------------------------------------------------------
    // MARK: Lebenszyklus
    // -------------------------------------------------------------------------

    /// Schließt das Fenster und gibt Ressourcen frei.
    open override func dispose() {
      fireWindowEvent(java.awt.event.WindowEvent.WINDOW_CLOSING)
      setVisible(false)
    }

    /// Layoutet alle Kinder und passt die Fenstergröße auf `preferredSize` an.
    open func pack() {
      // First pass: compute preferred sizes (children may have bounds=0 here)
      let ps = getPreferredSize()
      if ps.width > 0 && ps.height > 0 {
        bounds = java.awt.Rectangle(bounds.x, bounds.y, ps.width, ps.height)
      }
      // Second pass: now that bounds are set, lay out children into the real size
      validate()
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
