/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener for `JInternalFrame` state changes.
  ///
  /// Implement this protocol to receive notification when an internal frame is
  /// opened, closed, iconified, deiconified, activated, or deactivated.
  /// For convenience, use `InternalFrameAdapter` and override only the methods
  /// you need.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol InternalFrameListener : java.util.EventListener {

    /// Invoked when a `JInternalFrame` is opened for the first time.
    func internalFrameOpened(_ e: InternalFrameEvent)

    /// Invoked when a `JInternalFrame` is in the process of being closed.
    /// The close operation can be overridden at this point.
    func internalFrameClosing(_ e: InternalFrameEvent)

    /// Invoked when a `JInternalFrame` has been closed.
    func internalFrameClosed(_ e: InternalFrameEvent)

    /// Invoked when a `JInternalFrame` is iconified.
    func internalFrameIconified(_ e: InternalFrameEvent)

    /// Invoked when a `JInternalFrame` is deiconified.
    func internalFrameDeiconified(_ e: InternalFrameEvent)

    /// Invoked when a `JInternalFrame` is activated.
    func internalFrameActivated(_ e: InternalFrameEvent)

    /// Invoked when a `JInternalFrame` is deactivated.
    func internalFrameDeactivated(_ e: InternalFrameEvent)
  }
}
