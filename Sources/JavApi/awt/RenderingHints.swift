/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  // ---------------------------------------------------------------------------
  // MARK: - RenderingHints
  // ---------------------------------------------------------------------------

  /// A mutable map from rendering-hint keys to hint values.
  ///
  /// Mirrors `java.awt.RenderingHints`. Keys and values are typed structs so
  /// that only valid combinations can be stored.
  ///
  /// ```swift
  /// let hints = java.awt.RenderingHints()
  /// hints.put(.KEY_ANTIALIASING, .VALUE_ANTIALIAS_ON)
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public class RenderingHints {

    // =========================================================================
    // MARK: - Key
    // =========================================================================

    /// A typed key for a rendering hint.
    public struct Key: Hashable {
      let id: Int
      public static func == (lhs: Key, rhs: Key) -> Bool { lhs.id == rhs.id }
      public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    // =========================================================================
    // MARK: - Value
    // =========================================================================

    /// A typed value for a rendering hint.
    public struct Value: Hashable {
      let id: Int
      public static func == (lhs: Value, rhs: Value) -> Bool { lhs.id == rhs.id }
      public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    // =========================================================================
    // MARK: - Standard keys
    // =========================================================================

    nonisolated(unsafe) public static let KEY_ANTIALIASING       = Key(id:  1)
    nonisolated(unsafe) public static let KEY_RENDERING          = Key(id:  2)
    nonisolated(unsafe) public static let KEY_DITHERING          = Key(id:  3)
    nonisolated(unsafe) public static let KEY_TEXT_ANTIALIASING  = Key(id:  4)
    nonisolated(unsafe) public static let KEY_FRACTIONALMETRICS  = Key(id:  5)
    nonisolated(unsafe) public static let KEY_INTERPOLATION      = Key(id:  6)
    nonisolated(unsafe) public static let KEY_ALPHA_INTERPOLATION = Key(id: 7)
    nonisolated(unsafe) public static let KEY_COLOR_RENDERING    = Key(id:  8)
    nonisolated(unsafe) public static let KEY_STROKE_CONTROL     = Key(id:  9)
    nonisolated(unsafe) public static let KEY_TEXT_LCD_CONTRAST  = Key(id: 10)

    // =========================================================================
    // MARK: - Standard values — Antialiasing
    // =========================================================================

    nonisolated(unsafe) public static let VALUE_ANTIALIAS_ON      = Value(id: 101)
    nonisolated(unsafe) public static let VALUE_ANTIALIAS_OFF     = Value(id: 102)
    nonisolated(unsafe) public static let VALUE_ANTIALIAS_DEFAULT = Value(id: 103)

    // =========================================================================
    // MARK: - Standard values — Rendering quality
    // =========================================================================

    nonisolated(unsafe) public static let VALUE_RENDER_SPEED    = Value(id: 201)
    nonisolated(unsafe) public static let VALUE_RENDER_QUALITY  = Value(id: 202)
    nonisolated(unsafe) public static let VALUE_RENDER_DEFAULT  = Value(id: 203)

    // =========================================================================
    // MARK: - Standard values — Dithering
    // =========================================================================

    nonisolated(unsafe) public static let VALUE_DITHER_ENABLE   = Value(id: 301)
    nonisolated(unsafe) public static let VALUE_DITHER_DISABLE  = Value(id: 302)
    nonisolated(unsafe) public static let VALUE_DITHER_DEFAULT  = Value(id: 303)

    // =========================================================================
    // MARK: - Standard values — Text antialiasing
    // =========================================================================

    nonisolated(unsafe) public static let VALUE_TEXT_ANTIALIAS_ON      = Value(id: 401)
    nonisolated(unsafe) public static let VALUE_TEXT_ANTIALIAS_OFF     = Value(id: 402)
    nonisolated(unsafe) public static let VALUE_TEXT_ANTIALIAS_DEFAULT = Value(id: 403)
    nonisolated(unsafe) public static let VALUE_TEXT_ANTIALIAS_GASP    = Value(id: 404)
    nonisolated(unsafe) public static let VALUE_TEXT_ANTIALIAS_LCD_HRGB = Value(id: 405)
    nonisolated(unsafe) public static let VALUE_TEXT_ANTIALIAS_LCD_HBGR = Value(id: 406)
    nonisolated(unsafe) public static let VALUE_TEXT_ANTIALIAS_LCD_VRGB = Value(id: 407)
    nonisolated(unsafe) public static let VALUE_TEXT_ANTIALIAS_LCD_VBGR = Value(id: 408)

    // =========================================================================
    // MARK: - Standard values — Fractional metrics
    // =========================================================================

    nonisolated(unsafe) public static let VALUE_FRACTIONALMETRICS_ON      = Value(id: 501)
    nonisolated(unsafe) public static let VALUE_FRACTIONALMETRICS_OFF     = Value(id: 502)
    nonisolated(unsafe) public static let VALUE_FRACTIONALMETRICS_DEFAULT = Value(id: 503)

    // =========================================================================
    // MARK: - Standard values — Interpolation
    // =========================================================================

    nonisolated(unsafe) public static let VALUE_INTERPOLATION_NEAREST_NEIGHBOR = Value(id: 601)
    nonisolated(unsafe) public static let VALUE_INTERPOLATION_BILINEAR         = Value(id: 602)
    nonisolated(unsafe) public static let VALUE_INTERPOLATION_BICUBIC          = Value(id: 603)

    // =========================================================================
    // MARK: - Standard values — Alpha interpolation
    // =========================================================================

    nonisolated(unsafe) public static let VALUE_ALPHA_INTERPOLATION_SPEED    = Value(id: 701)
    nonisolated(unsafe) public static let VALUE_ALPHA_INTERPOLATION_QUALITY  = Value(id: 702)
    nonisolated(unsafe) public static let VALUE_ALPHA_INTERPOLATION_DEFAULT  = Value(id: 703)

    // =========================================================================
    // MARK: - Standard values — Color rendering
    // =========================================================================

    nonisolated(unsafe) public static let VALUE_COLOR_RENDER_SPEED   = Value(id: 801)
    nonisolated(unsafe) public static let VALUE_COLOR_RENDER_QUALITY = Value(id: 802)
    nonisolated(unsafe) public static let VALUE_COLOR_RENDER_DEFAULT = Value(id: 803)

    // =========================================================================
    // MARK: - Standard values — Stroke control
    // =========================================================================

    nonisolated(unsafe) public static let VALUE_STROKE_DEFAULT    = Value(id: 901)
    nonisolated(unsafe) public static let VALUE_STROKE_NORMALIZE  = Value(id: 902)
    nonisolated(unsafe) public static let VALUE_STROKE_PURE       = Value(id: 903)

    // =========================================================================
    // MARK: - Storage
    // =========================================================================

    private var hints: [Key: Value] = [:]

    // =========================================================================
    // MARK: - Constructors
    // =========================================================================

    public init() {}

    public init(_ hints: [Key: Value]) {
      self.hints = hints
    }

    // =========================================================================
    // MARK: - Map-like API
    // =========================================================================

    public func get(_ key: Key) -> Value? { hints[key] }

    public func put(_ key: Key, _ value: Value) { hints[key] = value }

    public func remove(_ key: Key) { hints.removeValue(forKey: key) }

    public func putAll(_ other: RenderingHints) {
      for (k, v) in other.hints { hints[k] = v }
    }

    public func containsKey(_ key: Key) -> Bool { hints[key] != nil }

    public func isEmpty() -> Bool { hints.isEmpty }

    public func size() -> Int { hints.count }

    public func clear() { hints.removeAll() }
  }
}
