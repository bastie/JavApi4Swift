/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.lang.reflect {

  /// Port of `java.lang.reflect.AnnotatedElement`.
  ///
  /// Represents an annotated construct of the program currently running in
  /// this VM. A construct is either an element or a type. If the construct
  /// is an element, the annotations are on the element; if the construct is
  /// a type, the annotations are on the use of the type.
  ///
  /// **Swift limitation:** Swift does not expose custom annotations at
  /// runtime. The `getAnnotation` / `getAnnotations` methods are provided
  /// as stubs for API compatibility and always return empty results.
  ///
  /// **TODO(SE-0385):** Once SE-0385 (Custom Reflection Metadata) is accepted
  /// and implemented, `getAnnotations()`, `getDeclaredAnnotations()`, and
  /// `isAnnotationPresent(_:)` can be backed by `Attribute.allInstances(of:)`
  /// to return real `@reflectionMetadata` attribute instances.
  /// Track: https://github.com/swiftlang/swift-evolution/blob/main/proposals/0385-custom-reflection-metadata.md
  ///
  /// Implemented by: `AccessibleObject` → `Field`, `Method`, `Constructor`
  ///
  /// - Since: Java 1.5
  public protocol AnnotatedElement: Sendable {

    /// Returns this element's annotation for the specified type, or `nil`
    /// if no such annotation is present.
    ///
    /// - Note: Always returns `nil` in this Swift port — annotations are
    ///   not available at runtime.
    /// - Since: Java 1.5
    func getAnnotation(_ annotationType: Any.Type) -> Any?

    /// Returns all annotations present on this element.
    ///
    /// - Note: Always returns an empty array in this Swift port.
    /// - Since: Java 1.5
    func getAnnotations() -> [Any]

    /// Returns all annotations directly present on this element.
    ///
    /// - Note: Always returns an empty array in this Swift port.
    /// - Since: Java 1.5
    func getDeclaredAnnotations() -> [Any]

    /// Returns `true` if an annotation for the specified type is present
    /// on this element.
    ///
    /// - Note: Always returns `false` in this Swift port.
    /// - Since: Java 1.5
    func isAnnotationPresent(_ annotationType: Any.Type) -> Bool
  }
}

// MARK: - Default implementations

extension java.lang.reflect.AnnotatedElement {

  public func getAnnotation(_ annotationType: Any.Type) -> Any? { nil }
  public func getAnnotations() -> [Any] { [] }
  public func getDeclaredAnnotations() -> [Any] { [] }
  public func isAnnotationPresent(_ annotationType: Any.Type) -> Bool { false }
}
