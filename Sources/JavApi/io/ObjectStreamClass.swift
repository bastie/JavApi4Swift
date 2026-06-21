/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// Serialization descriptor for a class in the object stream.
  ///
  /// Mirrors `java.io.ObjectStreamClass`.  In JavApi⁴Swift, full object
  /// (de)serialization is not implemented; this class exists so that ported
  /// Java code referencing `ObjectStreamClass.lookup(...)` compiles and
  /// returns a minimal descriptor.
  ///
  /// `getSerialVersionUID()` always returns `0` because Swift has no
  /// equivalent to Java's compile-time `serialVersionUID` field.
  ///
  /// - Since: Java 1.1
  public final class ObjectStreamClass: @unchecked Sendable {

    private let _name: String
    private let _serialVersionUID: Int64

    private init(_ name: String, _ uid: Int64 = 0) {
      self._name = name
      self._serialVersionUID = uid
    }

    // MARK: - Static factory

    /// Returns the serialization descriptor for the given type, or `nil` if
    /// the type does not conform to ``Serializable``.
    ///
    /// In JavApi⁴Swift every Swift type is treated as `Serializable`-capable
    /// and a descriptor is always returned.
    ///
    /// - Parameter cls: Any Swift metatype.
    /// - Returns: An `ObjectStreamClass` whose `getName()` returns the Swift
    ///   type name and whose `getSerialVersionUID()` returns `0`.
    /// - Since: Java 1.1
    public static func lookup(_ cls: Any.Type) -> ObjectStreamClass? {
      return ObjectStreamClass(String(reflecting: cls))
    }

    // MARK: - Instance methods

    /// Returns the fully-qualified name of the described class.
    ///
    /// - Since: Java 1.1
    public func getName() -> String {
      return _name
    }

    /// Returns the serial version UID of the described class.
    ///
    /// Always returns `0` in this implementation because Swift has no
    /// compile-time `serialVersionUID` equivalent.
    ///
    /// - Since: Java 1.1
    public func getSerialVersionUID() -> Int64 {
      return _serialVersionUID
    }
  }
}
