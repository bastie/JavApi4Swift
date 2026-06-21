/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// Utility methods for JavaBeans environments.
  ///
  /// Only the environment-query methods are ported. `instantiate()` requires
  /// `java.lang.Class` reflection and is not available — see NotImplemented.md.
  ///
  /// - Since: Java 1.1
  public final class Beans {

    nonisolated(unsafe) private static var _designTime: Bool = false
    nonisolated(unsafe) private static var _guiAvailable: Bool = true

    private init() {}

    // MARK: - Environment queries

    /// Returns `true` if the runtime is in design-time mode (e.g. inside an IDE
    /// bean builder). In JavApi⁴Swift this always returns `false` unless
    /// explicitly set via `setDesignTime(_:)`.
    public static func isDesignTime() -> Bool { _designTime }

    /// Sets design-time mode.
    public static func setDesignTime(_ designTime: Bool) { _designTime = designTime }

    /// Returns `true` if a GUI is available.
    /// Defaults to `true`; can be overridden for headless environments.
    public static func isGuiAvailable() -> Bool { _guiAvailable }

    /// Sets GUI-availability flag.
    public static func setGuiAvailable(_ guiAvailable: Bool) { _guiAvailable = guiAvailable }
  }
}
