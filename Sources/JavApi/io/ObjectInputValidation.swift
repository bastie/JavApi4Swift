/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// Callback interface to allow validation of objects within an object graph
  /// during deserialization.
  ///
  /// Implementations can be registered with ``ObjectInputStream`` via
  /// `registerValidation(_:priority:)` and are called after the entire object
  /// graph has been deserialized.
  ///
  /// Mirrors `java.io.ObjectInputValidation`.
  ///
  /// - Since: Java 1.1
  public protocol ObjectInputValidation {

    /// Validates the object.
    ///
    /// Called after the complete object graph has been read.  Throw
    /// ``InvalidObjectException`` if the object is invalid.
    ///
    /// - Throws: ``InvalidObjectException`` if the object cannot be validated.
    func validateObject() throws
  }
}
