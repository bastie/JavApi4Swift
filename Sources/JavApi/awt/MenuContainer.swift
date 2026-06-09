/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Interface for AWT components that can contain menus.
  ///
  /// Mirrors `java.awt.MenuContainer` from Java 1.0.
  /// The `postEvent` method belongs to the Java 1.0 event model and is
  /// deprecated since Java 1.1 — use `java.awt.event` listeners instead.
  ///
  /// - Since: JavaApi (Java 1.0)
  @MainActor
  public protocol MenuContainer: AnyObject {

    /// Returns the font used by this container.
    /// - Since: JavaApi (Java 1.0)
    func getFont() -> java.awt.Font

    /// Removes the specified menu component from this container.
    /// - Since: JavaApi (Java 1.0)
    func remove(_ comp: java.awt.MenuComponent)

    /// Dispatches an event to this container using the Java 1.0 event model.
    ///
    /// - Parameter evt: The event to dispatch.
    /// - Returns: `true` if the event was handled.
    /// - Since: JavaApi (Java 1.0)
    @available(*, deprecated, message: "Use java.awt.event listeners (Java 1.1+) instead.")
    @discardableResult
    func postEvent(_ evt: java.awt.Event) -> Bool
  }
}

// MARK: - Default implementations

extension java.awt.MenuContainer {
  /// Default: always returns `false` — Java 1.0 event dispatching is not active.
  @available(*, deprecated, message: "Use java.awt.event listeners (Java 1.1+) instead.")
  public func postEvent(_ evt: java.awt.Event) -> Bool { return false }

  /// Default no-op — override in classes that manage a menu component list.
  public func remove(_ comp: java.awt.MenuComponent) {}
}
