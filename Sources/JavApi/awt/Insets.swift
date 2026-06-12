/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  // ---------------------------------------------------------------------------
  // MARK: - Insets
  // ---------------------------------------------------------------------------

  /// Represents the borders of a container — the space left around the edges.
  ///
  /// Mirrors `java.awt.Insets`. Each field is in pixel units.
  ///
  /// ```swift
  /// let insets = java.awt.Insets(top: 10, left: 5, bottom: 10, right: 5)
  /// print(insets.top)   // → 10
  /// ```
  ///
  /// - Since: Java 1.0
  public class Insets : Equatable, CustomStringConvertible {
    public var description: String {self.toString()}
    

    // -------------------------------------------------------------------------
    // MARK: Fields  (Java field names kept for porting fidelity)
    // -------------------------------------------------------------------------

    /// Space at the top edge.
    public var top:    Int
    /// Space at the left edge.
    public var left:   Int
    /// Space at the bottom edge.
    public var bottom: Int
    /// Space at the right edge.
    public var right:  Int

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    /// Creates insets with the given border widths.
    public init(_ top: Int, _ left: Int, _ bottom: Int, _ right: Int) {
      self.top = top; self.left = left; self.bottom = bottom; self.right = right
    }

    /// Copy constructor.
    public convenience init(_ insets: Insets) {
      self.init(insets.top, insets.left, insets.bottom, insets.right)
    }

    /// Creates zero insets.
    public convenience init() {
      self.init(0, 0, 0, 0)
    }

    // -------------------------------------------------------------------------
    // MARK: Mutator
    // -------------------------------------------------------------------------

    /// Sets all four border widths at once.
    public func set(_ top: Int, _ left: Int, _ bottom: Int, _ right: Int) {
      self.top = top; self.left = left; self.bottom = bottom; self.right = right
    }

    // -------------------------------------------------------------------------
    // MARK: Object
    // -------------------------------------------------------------------------

    public func toString() -> String {
      "\(String(describing: type(of: self)))"
      + "[top=\(top),left=\(left),bottom=\(bottom),right=\(right)]"
    }

    public func equals(_ obj: AnyObject) -> Bool {
      guard let other = obj as? Insets else { return false }
      return self == other
    }
  }
}
