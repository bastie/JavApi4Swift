/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.applet {
  /// Interface representing the applet's environment — mirrors `java.applet.AppletContext` from Java 1.0.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public protocol AppletContext {
    /// - Parameter url: of audio clip
    /// - Returns: the AudioClip at the given URL.
    func getAudioClip(_ url: java.net.URL) -> any AudioClip
    /// - Parameter url: of image
    /// - Returns:  the Image at the given URL.
    func getImage(_ url: java.net.URL) -> java.awt.Image
    /// - Parameter name: name of wanted applet
    /// - Returns: the applet with the given name.
    func getApplet(_ name: String) -> Applet?
    /// - Returns an enumeration of all applets in the context.
    func getApplets() -> any java.util.Enumeration
    /// Shows the document at the given URL.
    /// - Parameter url: of document
    func showDocument(_ url: java.net.URL)
    /// Shows the document at the given URL in the named frame.
    /// - Parameters:
    ///   - url: of document
    ///   - target: name of target name
    func showDocument(_ url: java.net.URL, _ target: String)
    /// Shows a status message.
    /// - Parameter status: message to show
    func showStatus(_ status: String)
  }
}
