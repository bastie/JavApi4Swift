/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.applet {
  /// Interface connecting an applet to its browser environment.
  ///
  /// - Since: Java 1.0
  public protocol AppletStub {
    /// - Returns: true if the applet is active.
    func isActive() -> Bool
    /// - Returns: the URL of the document in which the applet is embedded.
    func getDocumentBase() -> java.net.URL
    /// - Returns: the URL of the directory containing the applet.
    func getCodeBase() -> java.net.URL
    /// - Returns: the value of the named parameter.
    func getParameter(_ name: String) -> String
    /// - Returns: the applet's context.
    func getAppletContext() -> any AppletContext
    /// Called when the applet wants to be resized.
    /// - Parameters:
    ///   - width: of new size
    ///   - height: of new size
    func appletResize(_ width: Int, _ height: Int)
  }
}
