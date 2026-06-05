/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {
  open class Dimension: Equatable {

    // -------------------------------------------------------------------------
    // MARK: Fields
    // -------------------------------------------------------------------------

    public var width:  Int
    public var height: Int

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    public init(_ width: Int, _ height: Int) {
      self.width = width; self.height = height
    }

    /// Creates a zero-size Dimension.
    public convenience init() { self.init(0, 0) }

    /// Copy constructor.
    public convenience init(_ d: Dimension) { self.init(d.width, d.height) }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    open func getWidth()  -> Double { Double(width)  }
    open func getHeight() -> Double { Double(height) }

    /// Returns a copy of this Dimension.
    open func getSize() -> Dimension { Dimension(self) }

    // -------------------------------------------------------------------------
    // MARK: Mutators
    // -------------------------------------------------------------------------

    open func setSize(_ width: Int, _ height: Int) {
      self.width = width; self.height = height
    }

    /// Sets size from another Dimension.
    open func setSize(_ d: Dimension) {
      setSize(d.width, d.height)
    }

    /// Sets size from Double values (truncated to Int, consistent with Java behaviour).
    open func setSize(_ width: Double, _ height: Double) {
      self.width  = Int(width)
      self.height = Int(height)
    }

    // -------------------------------------------------------------------------
    // MARK: Object
    // -------------------------------------------------------------------------

    open func toString() -> String {
      "\(String(describing: type(of: self))) [width=\(width),height=\(height)]"
    }

    open func equals(_ obj: AnyObject) -> Bool {
      guard let other = obj as? Dimension else { return false }
      return self == other
    }

    public static func == (lhs: Dimension, rhs: Dimension) -> Bool {
      lhs.width == rhs.width && lhs.height == rhs.height
    }
  }
}
