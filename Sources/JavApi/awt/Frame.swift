/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Ein Fenster mit Titelzeile und optionaler Menüleiste — mirrors `java.awt.Frame`.
  ///
  /// Erbt Sichtbarkeit, Lebenszyklus und Toolkit-Anbindung von `Window`.
  @MainActor
  open class Frame: Window {

    // Dekorations-Konstanten
    public static let DEFAULT_CURSOR    = 0
    public static let CROSSHAIR_CURSOR  = 1
    public static let TEXT_CURSOR       = 2
    public static let WAIT_CURSOR       = 3
    public static let ICONIFIED         = 1
    public static let MAXIMIZED_HORIZ   = 2
    public static let MAXIMIZED_VERT    = 4
    public static let MAXIMIZED_BOTH    = MAXIMIZED_HORIZ | MAXIMIZED_VERT
    public static let NORMAL            = 0

    // -------------------------------------------------------------------------
    // MARK: Eigenschaften
    // -------------------------------------------------------------------------

    public var title: String

    /// Zustand des Fensters (NORMAL, ICONIFIED, MAXIMIZED_BOTH …).
    public var extendedState: Int = Frame.NORMAL

    /// Ob das Fenster in der Größe verändert werden kann.
    public var resizable: Bool = true

    /// Die Menüleiste dieses Frames.
    private var _menuBar: MenuBar? = nil

    // -------------------------------------------------------------------------
    // MARK: Konstruktoren
    // -------------------------------------------------------------------------

    public init(_ title: String = "") {
      self.title = title
    }

    // -------------------------------------------------------------------------
    // MARK: Größe
    // -------------------------------------------------------------------------

    /// Setzt Breite und Höhe des Frames (Position bleibt 0,0).
    open override func setSize(_ width: Int, _ height: Int) {
      bounds = java.awt.Rectangle(0, 0, width, height)
    }

    // -------------------------------------------------------------------------
    // MARK: Titel
    // -------------------------------------------------------------------------

    public func getTitle() -> String      { title }
    public func setTitle(_ t: String)     { title = t }

    // -------------------------------------------------------------------------
    // MARK: Menüleiste
    // -------------------------------------------------------------------------

    public func getMenuBar() -> MenuBar? { _menuBar }

    public func setMenuBar(_ mb: MenuBar?) {
      _menuBar = mb
      // Plattform über die Änderung informieren
      java.awt.Toolkit.getDefaultToolkit().attachMenuBar(mb, to: self)
    }
  }
}
