/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Describes the language-sensitivity of component orientation.
  ///
  /// Mirrors `java.awt.ComponentOrientation`.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public final class ComponentOrientation: @unchecked Sendable {

    // =========================================================================
    // MARK: - Constants
    // =========================================================================

    /// Items run left-to-right, lines top-to-bottom (e.g. English).
    public static let LEFT_TO_RIGHT = ComponentOrientation(horizontal: true, leftToRight: true)

    /// Items run right-to-left, lines top-to-bottom (e.g. Arabic, Hebrew).
    public static let RIGHT_TO_LEFT = ComponentOrientation(horizontal: true, leftToRight: false)

    /// Orientation is unknown.
    public static let UNKNOWN = ComponentOrientation(horizontal: true, leftToRight: true)

    // =========================================================================
    // MARK: - Properties
    // =========================================================================

    private let horizontal: Bool
    private let leftToRight: Bool

    // =========================================================================
    // MARK: - Init (private — use static constants or getOrientation)
    // =========================================================================

    private init(horizontal: Bool, leftToRight: Bool) {
      self.horizontal = horizontal
      self.leftToRight = leftToRight
    }

    // =========================================================================
    // MARK: - Query
    // =========================================================================

    /// Returns `true` if the orientation is horizontal (line direction is LTR or RTL).
    public func isHorizontal() -> Bool { horizontal }

    /// Returns `true` if the line direction is left-to-right.
    public func isLeftToRight() -> Bool { leftToRight }

    // =========================================================================
    // MARK: - Factory
    // =========================================================================

    /// Returns the orientation appropriate for the given `Locale`.
    ///
    /// Currently returns `LEFT_TO_RIGHT` for all locales (stub).
    /// RTL locales (Arabic, Hebrew, Persian, Urdu) return `RIGHT_TO_LEFT`.
    public static func getOrientation(_ locale: java.util.Locale) -> ComponentOrientation {
      let rtlLanguages: Set<String> = ["ar", "he", "iw", "fa", "ur"]
      if rtlLanguages.contains(locale.getLanguage()) {
        return RIGHT_TO_LEFT
      }
      return LEFT_TO_RIGHT
    }
  }
}
