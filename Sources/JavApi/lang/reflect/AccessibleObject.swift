/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.lang.reflect {

  /// Port of `java.lang.reflect.AccessibleObject`.
  ///
  /// `AccessibleObject` is the base class for `Field`, `Method`, and
  /// `Constructor` objects. It provides the ability to flag a reflected
  /// object as suppressing default Java language access control checks.
  ///
  /// **Swift mapping:**
  /// - `setAccessible(true)` has no runtime effect in this port because
  ///   Swift does not enforce access control at runtime. The flag is stored
  ///   for API compatibility only.
  /// - Annotation methods are inherited from `AnnotatedElement` and always
  ///   return empty results (Swift does not expose annotations at runtime).
  ///
  /// - Since: Java 1.1
  open class AccessibleObject: AnnotatedElement, @unchecked Sendable {

    // MARK: - Accessible flag

    /// Stored accessible flag. In Java this suppresses access checks;
    /// in Swift it is purely informational.
    private var _accessible: Bool = false

    // MARK: - Init

    /// Designated initialiser. Accessible only to subclasses within this
    /// module — mirrors Java's `protected AccessibleObject()`.
    public init() {}

    // MARK: - Public API

    /// Sets the `accessible` flag for this object.
    ///
    /// A value of `true` indicates that the reflected object should suppress
    /// Java language access checking when it is used. In this Swift port
    /// access checking is never enforced, so calling this method has no
    /// behavioural effect — the flag is stored for API compatibility only.
    ///
    /// - Parameter flag: The new value for the accessible flag.
    /// - Since: Java 1.1
    public func setAccessible(_ flag: Bool) {
      _accessible = flag
    }

    /// Returns the value of this object's `accessible` flag.
    ///
    /// - Since: Java 1.1
    public func isAccessible() -> Bool {
      return _accessible
    }

    /// Sets the `accessible` flag for an array of objects in a single call.
    ///
    /// - Parameters:
    ///   - array: The array of `AccessibleObject` instances to update.
    ///   - flag: The new accessible flag value.
    /// - Since: Java 1.1
    public static func setAccessible(_ array: [AccessibleObject], _ flag: Bool) {
      for obj in array { obj.setAccessible(flag) }
    }

    // MARK: - AnnotatedElement (stubs — Swift has no runtime annotations)

    public func getAnnotation(_ annotationType: Any.Type) -> Any? { nil }
    public func getAnnotations() -> [Any] { [] }
    public func getDeclaredAnnotations() -> [Any] { [] }
    public func isAnnotationPresent(_ annotationType: Any.Type) -> Bool { false }

    // MARK: - CustomStringConvertible

    /// Returns a string description of this object. Subclasses override
    /// `toString()` to provide type-specific information.
    open func toString() -> String {
      return "\(type(of: self))"
    }

    public var description: String { toString() }
  }
}
