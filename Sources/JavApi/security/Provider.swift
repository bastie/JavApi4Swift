/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.security {
  open class Provider: CustomStringConvertible /*: java.util.Properties*/ {

    /// Internal registry: algorithm name → KeyPairGenerator factory.
    /// Populated by concrete Provider subclasses.
    public var _keyPairGeneratorFactories: [String: () -> KeyPairGenerator] = [:]

    /// Internal registry: algorithm name → Signature factory.
    /// Populated by concrete Provider subclasses.
    public var _signatureFactories: [String: () -> Signature] = [:]

    public init () {}

    // MARK: - Java API

    /// Returns the name of this provider.
    ///
    /// The default implementation returns the Swift class name.
    /// Subclasses should override to return a stable, human-readable name.
    ///
    /// Mirrors `java.security.Provider.getName()` (Java 1.1).
    open func getName() -> String { String(describing: type(of: self)) }

    /// Returns the version number of this provider.
    ///
    /// Mirrors `java.security.Provider.getVersion()` (Java 1.1).
    open func getVersion() -> Double { 0.0 }

    /// Returns a human-readable description of this provider.
    ///
    /// Mirrors `java.security.Provider.getInfo()` (Java 1.1).
    open func getInfo() -> String { "" }

    /// Returns a string in the form `"<name> version <version>"`.
    ///
    /// Mirrors `java.security.Provider.toString()` (Java 1.1).
    open func toString() -> String { "\(getName()) version \(getVersion())" }

    // MARK: - Swift CustomStringConvertible

    /// Bridges Java's `toString()` to Swift's string-interpolation protocol.
    public var description: String { toString() }

    open class Service {}
  }
}
