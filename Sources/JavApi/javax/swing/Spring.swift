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
  /// Note: In Java `Spring` is an abstract class
  ///
  /// - Since: Java 1.4
  @MainActor
  open class Spring {

    // -------------------------------------------------------------------------
    // MARK: Special sentinel
    // -------------------------------------------------------------------------

    /// Returned by `getValue()` when the spring's value has not been set.
    public static let UNSET: Int = -2147483648 // Java constants description has an exact value

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

    public init(_ min: Int, _ preferred: Int, _ max: Int) {
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
    public static func constant(_ preferred: Int) -> Spring {
      Spring(preferred, preferred, preferred)
    }

    /// A spring with independent minimum, preferred, and maximum.
    public static func constant(_ min: Int, _ preferred: Int, _ max: Int) -> Spring {
      Spring(min, preferred, max)
    }

    /// A spring whose value tracks the preferred width of `comp`.
    public static func width(_ comp: java.awt.Component) -> Spring {
      let preferredSize = comp.getPreferredSize()
      let width  = preferredSize.width > 0 ? preferredSize.width : comp.getWidth()
      return Spring(0, width, width)
    }

    /// A spring whose value tracks the preferred height of `comp`.
    public static func height(_ comp: java.awt.Component) -> Spring {
      let preferredSize = comp.getPreferredSize()
      let height  = preferredSize.height > 0 ? preferredSize.height : comp.getHeight()
      return Spring(0, height, height)
    }

    /// Returns a spring whose value is the sum of `s1` and `s2`.
    public static func sum(_ s1: Spring, _ s2: Spring) -> Spring {
      Spring( (s1._min + s2._min), (s1._preferred + s2._preferred), (s1._max + s2._max) )
    }

    /// Returns a spring whose value is the maximum of `s1` and `s2`.
    public static func max(_ s1: Spring, _ s2: Spring) -> Spring {
      Spring ( Swift.max(s1._min, s2._min), Swift.max(s1._preferred, s2._preferred), Swift.max(s1._max, s2._max))
    }

    /// Returns a spring whose value is the negation of `s`.
    public static func minus(_ s: Spring) -> Spring {
      Spring(-s._max, -s._preferred, -s._min)
    }
    
    /// - Since: Java 5
    public static func scale(_ s: Spring, _ factor: Float) -> Spring {
      Spring( Int(Float(s._min) * factor), Int(Float(s._preferred) * factor), Int(Float(s._max) * factor))
    }
  }
}
