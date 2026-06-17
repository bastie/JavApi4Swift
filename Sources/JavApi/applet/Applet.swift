/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.applet {
  /// Base class for all applets — mirrors `java.applet.Applet` from Java 1.0.
  ///
  /// Applet extends Panel, which provides the AWT component hierarchy.
  ///
  @MainActor
  open class Applet: java.awt.Panel {

    private var stub: (any AppletStub)?

    public override init() {
      super.init()
    }

    /// Sets the applet's stub (called by the browser/applet runner).
    ///
    /// - Parameter stub: The AppletStub connecting this applet to its environment.
    public func setStub(_ stub: any AppletStub) {
      self.stub = stub
    }

    /// - Returns: the applet's stub.
    public func getAppletContext() -> (any AppletContext)? {
      return stub?.getAppletContext()
    }

    /// - Returns: the URL of the document in which this applet is embedded.
    public func getDocumentBase() -> java.net.URL? {
      return stub?.getDocumentBase()
    }

    /// - Returns: the URL of the directory containing this applet.
    public func getCodeBase() -> java.net.URL? {
      return stub?.getCodeBase()
    }

    /// - Parameter name: of paremater
    /// - Returns: the value of the named parameter from the HTML tag.
    public func getParameter(_ name: String) -> String? {
      return stub?.getParameter(name)
    }

    /// - Returns: true if the applet is active.
    public func isActive() -> Bool {
      return stub?.isActive() ?? false
    }

    // MARK: - Applet lifecycle (to be overridden)

    /// Called by the browser when the applet is first loaded.
    open func init_() {}

    /// Called by the browser to start the applet.
    open func start() {}

    /// Called by the browser to stop the applet.
    open func stop_() {}

    /// Called by the browser to destroy the applet.
    open func destroy() {}

    /// - Returns: a string containing information about the applet.
    open func getAppletInfo() -> String? { return nil }

    /// - Returns: information about the parameters the applet understands.
    open func getParameterInfo() -> [[String]]? { return nil }
    
    /// - Returns: Applet specific locale if set or the system default locale
    open override func getLocale() -> java.util.Locale {
      if let locale = _componentLocale {
        return locale
      }
      else {
        return java.util.Locale.getDefault()
      }
    }
  }
}
