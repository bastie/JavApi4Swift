/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Interface for objects that handle the behaviour of `JInternalFrame`s inside
  /// a `JDesktopPane`.
  ///
  /// `DesktopManager` separates the policy for moving, resizing, iconifying, and
  /// closing internal frames from the frames themselves.  `JDesktopPane` installs
  /// a `DefaultDesktopManager` by default; replace it with a custom
  /// implementation to get different MDI behaviour.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol DesktopManager: AnyObject {

    /// Called when `frame` should be opened for the first time.
    func openFrame(_ frame: JInternalFrame)

    /// Called when `frame` is about to be closed.
    func closeFrame(_ frame: JInternalFrame)

    /// Called when `frame` should be maximised.
    func maximizeFrame(_ frame: JInternalFrame)

    /// Called when `frame` should be restored from maximised state.
    func minimizeFrame(_ frame: JInternalFrame)

    /// Called when `frame` should be iconified.
    func iconifyFrame(_ frame: JInternalFrame)

    /// Called when `frame` should be deiconified.
    func deiconifyFrame(_ frame: JInternalFrame)

    /// Called to give `frame` focus / make it the active internal frame.
    func activateFrame(_ frame: JInternalFrame)

    /// Called when `frame` loses focus.
    func deactivateFrame(_ frame: JInternalFrame)

    /// Called at the start of a drag operation on `frame`.
    func beginDraggingFrame(_ frame: JInternalFrame)

    /// Called during a drag to move `frame` to (`newX`, `newY`).
    func dragFrame(_ frame: JInternalFrame, _ newX: Int, _ newY: Int)

    /// Called at the end of a drag operation on `frame`.
    func endDraggingFrame(_ frame: JInternalFrame)

    /// Called at the start of a resize operation on `frame`.
    func beginResizingFrame(_ frame: JInternalFrame, _ direction: Int)

    /// Called during a resize to set `frame`'s new bounds.
    func resizeFrame(_ frame: JInternalFrame, _ newX: Int, _ newY: Int, _ newWidth: Int, _ newHeight: Int)

    /// Called at the end of a resize operation on `frame`.
    func endResizingFrame(_ frame: JInternalFrame)

    /// Moves and resizes `frame` to the specified bounds.
    func setBoundsForFrame(_ frame: JInternalFrame, _ newX: Int, _ newY: Int, _ newWidth: Int, _ newHeight: Int)
  }
}
