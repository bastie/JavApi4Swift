/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  public class WindowEvent: ComponentEvent, @unchecked Sendable {

    public static let WINDOW_FIRST          = 200
    public static let WINDOW_LAST           = 209
    public static let WINDOW_OPENED         = 200
    public static let WINDOW_CLOSING        = 201
    public static let WINDOW_CLOSED         = 202
    public static let WINDOW_ICONIFIED      = 203
    public static let WINDOW_DEICONIFIED    = 204
    public static let WINDOW_ACTIVATED      = 205
    public static let WINDOW_DEACTIVATED    = 206
    public static let WINDOW_GAINED_FOCUS   = 207
    public static let WINDOW_LOST_FOCUS     = 208
    public static let WINDOW_STATE_CHANGED  = 209

    public override init(_ source: java.awt.Component, _ id: Int) {
      super.init(source, id)
    }

    public func getWindow() -> java.awt.Component { getComponent() }
  }
}
