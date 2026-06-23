/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  // ---------------------------------------------------------------------------
  // MARK: - Spring
  // ---------------------------------------------------------------------------

  /// A distance value with minimum, preferred, and maximum extents —
  /// mirrors `javax.swing.Spring`.
  ///
  /// Springs are used by `SpringLayout` to describe the gaps and sizes of
  /// components.  The three factory methods cover the most common cases:
  ///
  /// ```swift
  /// // Fixed gap of 8 px
  /// let gap = javax.swing.Spring.constant(8)
  ///
  /// // Flexible: min 4, preferred 8, max 16
  /// let flex = javax.swing.Spring.constant(4, 8, 16)
  ///
  /// // Derived from a component's width
  /// let w = javax.swing.Spring.width(button)
  /// ```
  ///
  /// > **AI hint:** `Spring` is a value-like object, but it is a *class* in Java
  /// > (and here) so it can be stored by reference in constraint dictionaries.
  ///
  /// - Since: JavApi > 0.x (Java 1.4)
  @MainActor
  public class Spring {

    // -------------------------------------------------------------------------
    // MARK: Special sentinel
    // -------------------------------------------------------------------------

    /// Returned by `getValue()` when the spring's value has not been set.
    public static let UNSET: Int = Int.min

    // -------------------------------------------------------------------------
    // MARK: Stored extents
    // -------------------------------------------------------------------------

    private let _min:       Int
    private let _preferred: Int
    private let _max:       Int
    private var _value:     Int

    // -------------------------------------------------------------------------
    // MARK: Init (internal — use factory methods)
    // -------------------------------------------------------------------------

    fileprivate init(min: Int, preferred: Int, max: Int) {
      self._min       = min
      self._preferred = preferred
      self._max       = max
      self._value     = Spring.UNSET
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getMinimumValue()  -> Int { _min       }
    public func getPreferredValue() -> Int { _preferred }
    public func getMaximumValue()  -> Int { _max       }

    public func getValue() -> Int {
      _value == Spring.UNSET ? _preferred : _value
    }

    public func setValue(_ value: Int) {
      _value = value
    }

    // -------------------------------------------------------------------------
    // MARK: Factory methods
    // -------------------------------------------------------------------------

    /// A spring with fixed minimum, preferred, and maximum.
    public static func constant(_ value: Int) -> Spring {
      Spring(min: value, preferred: value, max: value)
    }

    /// A spring with independent minimum, preferred, and maximum.
    public static func constant(_ min: Int, _ preferred: Int, _ max: Int) -> Spring {
      Spring(min: min, preferred: preferred, max: max)
    }

    /// A spring whose value tracks the preferred width of `comp`.
    public static func width(_ comp: java.awt.Component) -> Spring {
      let ps = comp.getPreferredSize()
      let w  = ps.width > 0 ? ps.width : comp.getWidth()
      return Spring(min: 0, preferred: w, max: w)
    }

    /// A spring whose value tracks the preferred height of `comp`.
    public static func height(_ comp: java.awt.Component) -> Spring {
      let ps = comp.getPreferredSize()
      let h  = ps.height > 0 ? ps.height : comp.getHeight()
      return Spring(min: 0, preferred: h, max: h)
    }

    /// Returns a spring whose value is the sum of `s1` and `s2`.
    public static func sum(_ s1: Spring, _ s2: Spring) -> Spring {
      Spring(
        min:       s1._min       + s2._min,
        preferred: s1._preferred + s2._preferred,
        max:       s1._max       + s2._max
      )
    }

    /// Returns a spring whose value is the maximum of `s1` and `s2`.
    public static func max(_ s1: Spring, _ s2: Spring) -> Spring {
      Spring(
        min:       Swift.max(s1._min,       s2._min),
        preferred: Swift.max(s1._preferred, s2._preferred),
        max:       Swift.max(s1._max,       s2._max)
      )
    }

    /// Returns a spring whose value is the negation of `s`.
    public static func minus(_ s: Spring) -> Spring {
      Spring(min: -s._max, preferred: -s._preferred, max: -s._min)
    }
  }
}
