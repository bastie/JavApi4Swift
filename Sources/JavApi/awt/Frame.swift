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

    // Cursor-Konstanten (Java 1.0)
    public static let DEFAULT_CURSOR      = 0
    public static let CROSSHAIR_CURSOR    = 1
    public static let TEXT_CURSOR         = 2
    public static let WAIT_CURSOR         = 3
    public static let SW_RESIZE_CURSOR    = 4
    public static let SE_RESIZE_CURSOR    = 5
    public static let NW_RESIZE_CURSOR    = 6
    public static let NE_RESIZE_CURSOR    = 7
    public static let N_RESIZE_CURSOR     = 8
    public static let S_RESIZE_CURSOR     = 9
    public static let W_RESIZE_CURSOR     = 10
    public static let E_RESIZE_CURSOR     = 11
    public static let HAND_CURSOR         = 12
    public static let MOVE_CURSOR         = 13
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
