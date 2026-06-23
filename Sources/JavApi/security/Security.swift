/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security {

  /// Manages the registered security providers and their algorithms.
  ///
  /// This is a static utility class — it cannot be instantiated.
  ///
  /// Mirrors `java.security.Security` (Java 1.1).
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  public final class Security {

    // MARK: - Provider registry (ordered list, thread-unsafe by design — mirrors Java)

    nonisolated(unsafe) private static var providers: [Provider] = [SwiftMessageDigestServiceProvider()]

    // MARK: - Private constructor

    private init() {}

    // MARK: - Provider management

    /// Returns an array containing all the installed providers.
    public static func getProviders() -> [Provider] { providers }

    /// Returns the provider with the given name, or `nil` if not installed.
    public static func getProvider(_ name: String) -> Provider? {
      providers.first { $0.getName() == name }
    }

    /// Adds a new provider at the end of the preference order.
    ///
    /// - Parameter provider: The provider to add.
    /// - Returns: The preference position (1-based) at which the provider was
    ///   added, or -1 if the provider was already installed.
    @discardableResult
    public static func addProvider(_ provider: Provider) -> Int {
      let name = provider.getName()
      guard !providers.contains(where: { $0.getName() == name }) else {
        return -1
      }
      providers.append(provider)
      return providers.count
    }

    /// Adds a new provider at the given position in the preference order.
    ///
    /// A position of 1 makes the provider the most preferred.
    ///
    /// - Parameters:
    ///   - provider: The provider to add.
    ///   - position: The preference position (1-based).
    /// - Returns: The actual position at which the provider was inserted,
    ///   or -1 if already installed.
    @discardableResult
    public static func insertProviderAt(_ provider: Provider, _ position: Int) -> Int {
      let name = provider.getName()
      guard !providers.contains(where: { $0.getName() == name }) else {
        return -1
      }
      let idx = Swift.max(0, Swift.min(position - 1, providers.count))
      providers.insert(provider, at: idx)
      return idx + 1
    }

    /// Removes the provider with the given name.
    ///
    /// Does nothing if the provider is not installed.
    public static func removeProvider(_ name: String) {
      providers.removeAll { $0.getName() == name }
    }

    /// Returns the names of all algorithms available for the given service
    /// type (e.g. `"MessageDigest"`, `"KeyPairGenerator"`, `"Signature"`).
    ///
    /// This implementation delegates to provider-supplied algorithm lists.
    public static func getAlgorithms(_ serviceName: String) -> Set<String> {
      var result = Set<String>()
      for provider in providers {
        switch serviceName {
        case "KeyPairGenerator":
          provider._keyPairGeneratorFactories.keys.forEach { result.insert($0) }
        case "Signature":
          provider._signatureFactories.keys.forEach { result.insert($0) }
        case "MessageDigest":
          // Built-in: expose the algorithms the Swift provider supports
          for alg in SwiftMessageDigestProvidedAlgorithm.allCases {
            result.insert(alg.rawValue)
          }
        default:
          break
        }
      }
      return result
    }

    /// Returns the value of a security property.
    /// - Parameter key: The property key.
    /// - Returns: The property value, or `nil` if not set.
    public static func getProperty(_ key: String) -> String? { nil }

    /// Sets a security property.
    public static func setProperty(_ key: String, _ datum: String) {
      // no-op in this implementation
    }
  }
}
