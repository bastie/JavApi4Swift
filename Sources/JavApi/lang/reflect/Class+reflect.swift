/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.lang.Class {

  // MARK: - Reflection: Field access

  /// Returns an array of `Field` objects reflecting all the fields declared
  /// by the class or interface represented by this `Class` object.
  ///
  /// Uses Swift's `Mirror` API to enumerate stored properties of a given
  /// instance. Unlike Java, Swift reflection requires an actual instance —
  /// pure type metadata is not sufficient.
  ///
  /// - Parameter instance: A live instance of the class to introspect.
  ///   Pass any object of the target type.
  /// - Returns: All stored properties of the instance as `Field` objects.
  ///
  /// **Limitations:**
  /// - Computed properties are not visible to `Mirror` and are not returned.
  /// - Static properties are not visible to `Mirror` and are not returned.
  /// - `Field.set()` is unavailable without a registered `WritableKeyPath`.
  ///
  /// - Since: Java 1.1
  public func getDeclaredFields(of instance: Any) -> [java.lang.reflect.Field] {
    return Self.fields(of: instance, declaringClass: self, inherited: false)
  }

  /// Returns an array of `Field` objects reflecting all the accessible public
  /// fields of the class or interface represented by this `Class` object.
  ///
  /// Includes fields from superclasses (visible via `Mirror.superclassMirror`).
  ///
  /// - Parameter instance: A live instance of the class to introspect.
  /// - Returns: All public stored properties, including inherited ones.
  ///
  /// - Since: Java 1.1
  public func getFields(of instance: Any) -> [java.lang.reflect.Field] {
    return Self.fields(of: instance, declaringClass: self, inherited: true)
  }

  // MARK: - Internal helper

  private static func fields(
    of instance: Any,
    declaringClass: java.lang.Class,
    inherited: Bool
  ) -> [java.lang.reflect.Field] {
    var result: [java.lang.reflect.Field] = []
    var mirror: Mirror? = Mirror(reflecting: instance)

    while let m = mirror {
      for child in m.children {
        guard let label = child.label, !label.isEmpty else { continue }
        // Skip compiler-generated backing storage labels (start with "_$")
        if label.hasPrefix("_$") { continue }

        let capturedLabel = label
        let field = java.lang.reflect.Field(
          name: capturedLabel,
          declaringClass: declaringClass,
          getter: { obj in
            let childMirror = Mirror(reflecting: obj)
            return childMirror.children.first(where: { $0.label == capturedLabel })?.value
          }
          // setter intentionally nil: Mirror is read-only
        )
        result.append(field)
      }

      // Walk up the superclass chain only for getFields()
      mirror = inherited ? m.superclassMirror : nil
    }

    return result
  }
}
