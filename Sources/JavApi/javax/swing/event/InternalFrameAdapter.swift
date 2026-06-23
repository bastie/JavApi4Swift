/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// An abstract adapter class for receiving `JInternalFrame` events.
  ///
  /// Extend this class and override only the methods you need.
  /// All methods are no-ops by default.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class InternalFrameAdapter: InternalFrameListener, @unchecked Sendable {

    public init() {}

    open func internalFrameOpened(_ e: InternalFrameEvent) {}

    open func internalFrameClosing(_ e: InternalFrameEvent) {}

    open func internalFrameClosed(_ e: InternalFrameEvent) {}

    open func internalFrameIconified(_ e: InternalFrameEvent) {}

    open func internalFrameDeiconified(_ e: InternalFrameEvent) {}

    open func internalFrameActivated(_ e: InternalFrameEvent) {}

    open func internalFrameDeactivated(_ e: InternalFrameEvent) {}
  }
}
