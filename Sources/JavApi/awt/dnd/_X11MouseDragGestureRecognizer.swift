/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)

extension java.awt.dnd {

  /// Linux/X11-spezifischer `MouseDragGestureRecognizer`.
  ///
  /// `_X11WindowHost` ruft `mousePressedAt(_:_:)`, `mouseDraggedAt(_:_:)` und
  /// `mouseReleased()` aus dem Haupt-EventLoop auf.  Sobald der
  /// Chebyshev-Abstand vom Druckursprung `DragSource.getDragThreshold()`
  /// überschreitet, wird `fireDragGestureRecognized` ausgelöst, das alle
  /// `DragGestureListener` benachrichtigt.  Der Listener kann dann
  /// `event.startDrag(…)` → `_startXDNDDrag(…)` aufrufen.
  ///
  /// ### XDND-Protokoll (Schritt 5)
  ///
  /// `_startXDNDDrag` startet eine Drag-Session via XDND:
  /// - Intra-App: Dispatch direkt über `_X11WindowHost`-Methoden.
  /// - Cross-App:  `XdndEnter` / `XdndPosition` / `XdndDrop` ClientMessages
  ///   werden an das X11-Fenster unter dem Cursor gesendet.
  ///
  /// - Since: Java 1.2 (X11-Backend, Schritt 5)
  @MainActor
  public final class _X11MouseDragGestureRecognizer: MouseDragGestureRecognizer {

    // ── Initialisierer ────────────────────────────────────────────────────────

    public override init(dragSource: DragSource,
                         component: java.awt.Component,
                         dragAction: Int) {
      super.init(dragSource: dragSource, component: component, dragAction: dragAction)
    }

    // ── Einstiegspunkte von _X11WindowHost ────────────────────────────────────

    /// Einstiegspunkt aus dem X11-ButtonPress-Handler.
    public func mousePressedAt(_ x: Int, _ y: Int) {
      mousePressed(x, y)
    }

    /// Einstiegspunkt aus dem X11-MotionNotify-Handler.
    ///
    /// Delegiert zur plattformunabhängigen Schwellen-Logik; kann synchron
    /// eine Geste auslösen und `_startXDNDDrag` via Listener aufrufen.
    public func mouseDraggedAt(_ x: Int, _ y: Int) {
      mouseDragged(x, y)
    }

    /// Einstiegspunkt aus dem X11-ButtonRelease-Handler.
    public override func mouseReleased() {
      super.mouseReleased()
    }

    // ── Einstiegspunkt aus DragGestureEvent.startDrag (Linux-Pfad) ───────────

    /// Startet die DnD-Operation via XDND-Protokoll.
    ///
    /// Ermittelt das X11-Fenster unter dem Cursor und unterscheidet:
    /// - **Intra-App**: Dispatch direkt über `_X11WindowHost`.
    /// - **Cross-App**: ClientMessages `XdndEnter` / `XdndPosition` senden,
    ///   auf `XdndStatus` warten und schließlich `XdndDrop` oder `XdndLeave`
    ///   senden.
    ///
    /// Nach Abschluss wird `DragSourceDropEvent` auf dem `DragSourceListener`
    /// ausgelöst.
    public func _startXDNDDrag(
      transferable: any java.awt.datatransfer.Transferable,
      cursor: java.awt.Cursor?,
      dsl: (any DragSourceListener)?
    ) {
      let host = _X11WindowHost.shared
      host._xdndBeginDrag(
        from: component,
        transferable: transferable,
        dragAction: sourceActions,
        dsl: dsl
      )
    }
  }
}

#endif // os(Linux) || os(FreeBSD)
