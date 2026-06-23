/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.lang.reflect {

  /// Port of `java.lang.reflect.Field`.
  ///
  /// A `Field` provides information about, and dynamic access to, a single
  /// field of a class or an interface.
  ///
  /// **Java class hierarchy:**
  /// `Object` → `AccessibleObject` → `Field` (+ `Member`, `AnnotatedElement`)
  ///
  /// **Swift limitations:**
  /// - `get(_:)` is implemented via `Mirror` and works for all Swift types.
  /// - `set(_:value:)` requires a `WritableKeyPath` registered at construction
  ///   time (via `Class.getDeclaredFields()`). Without it, throws
  ///   `UnsupportedOperationException`.
  /// - `getModifiers()` always returns `Modifier.PUBLIC` because Swift does
  ///   not expose access-level information at runtime.
  /// - Annotation methods inherited from `AccessibleObject` always return
  ///   empty results.
  ///
  /// - Since: Java 1.1
  open class Field: AccessibleObject, Member, @unchecked Sendable {

    // MARK: - Stored state

    private let _name: String
    private let _declaringClass: java.lang.Class
    private let _getter: @Sendable (Any) -> Any?
    private let _setter: (@Sendable (inout Any, Any?) throws -> Void)?

    // MARK: - Init

    /// Designated initialiser used by `Class.getDeclaredFields()`.
    ///
    /// - Parameters:
    ///   - name: The property name as returned by `Mirror`.
    ///   - declaringClass: The `Class` object that owns this field.
    ///   - getter: Closure that reads the field value from an instance.
    ///   - setter: Optional closure that writes a value into a mutable
    ///     instance. Pass `nil` when no `WritableKeyPath` is available.
    public init(
      name: String,
      declaringClass: java.lang.Class,
      getter: @escaping @Sendable (Any) -> Any?,
      setter: (@Sendable (inout Any, Any?) throws -> Void)? = nil
    ) {
      self._name = name
      self._declaringClass = declaringClass
      self._getter = getter
      self._setter = setter
      super.init()
    }

    // MARK: - Member conformance

    public func getDeclaringClass() -> java.lang.Class { _declaringClass }

    public func getName() -> String { _name }

    /// Swift does not expose access modifiers at runtime.
    /// Always returns `Modifier.PUBLIC` as a best-effort value.
    ///
    /// **TODO(SE-0379):** Once SE-0379 (Opt-In Reflection Metadata) is accepted,
    /// this method can return actual access modifier flags from compiler-emitted
    /// reflection metadata instead of always returning `PUBLIC`.
    public func getModifiers() -> Int { Modifier.PUBLIC }

    /// Swift-generated backing fields cannot be reliably detected;
    /// always returns `false`.
    public func isSynthetic() -> Bool { false }

    // MARK: - Field read access

    /// Returns the value of the field represented by this `Field`, on the
    /// specified object.
    ///
    /// Uses `Mirror` to inspect the object's stored properties.
    ///
    /// - Parameter obj: The object from which the field value is extracted.
    ///   Pass `nil` for static fields (not yet supported).
    /// - Returns: The value of the represented field in `obj`.
    /// - Throws: `NullPointerException` if `obj` is `nil`;
    ///           `IllegalArgumentException` if the field is not found.
    /// - Since: Java 1.1
    public func get(_ obj: Any?) throws -> Any? {
      guard let obj = obj else {
        throw NullPointerException("Field.get: object is null")
      }
      return _getter(obj)
    }

    // MARK: - Field write access

    /// Sets the field represented by this `Field` on the specified object
    /// to the specified new value.
    ///
    /// Requires a `setter` closure to have been provided at construction time.
    ///
    /// - Parameters:
    ///   - obj: The object whose field should be modified (passed `inout`
    ///     because Swift value types require mutation through the original).
    ///   - value: The new value for the field.
    /// - Throws: `UnsupportedOperationException` if no setter was registered;
    ///           any error thrown by the setter closure itself.
    /// - Since: Java 1.1
    public func set(_ obj: inout Any, value: Any?) throws {
      guard let setter = _setter else {
        throw UnsupportedOperationException(
          "Field.set: no WritableKeyPath registered for '\(_name)'"
        )
      }
      try setter(&obj, value)
    }

    // MARK: - Type information

    /// Returns the runtime type of this field as observed via `Mirror` on a
    /// live instance.
    ///
    /// Unlike Java's `getType()` — which works purely from type metadata —
    /// this Swift implementation requires an actual instance because Swift's
    /// runtime type system does not expose stored-property metadata without
    /// one.
    ///
    /// - Parameter sample: Any instance of the declaring class.
    /// - Returns: The `Any.Type` of the field value, or `nil` if the value
    ///   is `nil` or the field is not found.
    public func getGenericType(from sample: Any) -> Any.Type? {
      guard let value = _getter(sample) else { return nil }
      return type(of: value)
    }

    // MARK: - toString

    open override func toString() -> String {
      return "field \(_name) in \(_declaringClass.getName())"
    }
  }
}
