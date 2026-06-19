/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// =============================================================================
// MARK: - _ServiceLoaderConfig (non-generic helper — Swift forbids static
//         stored properties in generic types)
// =============================================================================

/// Internal singleton that holds the global service search path.
/// Lives outside the generic `ServiceLoader<VTable>` because Swift does not
/// allow static stored properties in generic types.
private enum _ServiceLoaderConfig {

  nonisolated(unsafe) static var searchPaths: [String] = {
    var paths: [String] = []
    if let envPath = ProcessInfo.processInfo.environment["JAVAPI_SERVICES_PATH"] {
      paths.append(contentsOf: envPath.components(separatedBy: ":"))
    }
    if let execURL = Bundle.main.executableURL {
      paths.append(execURL.deletingLastPathComponent()
                          .appendingPathComponent("services").path)
    }
#if os(Windows)
    if let appData = ProcessInfo.processInfo.environment["APPDATA"] {
      paths.append((appData as NSString).appendingPathComponent("JavApi\\services"))
    }
#else
    paths.append("/usr/share/javapi/services")
#endif
    return paths
  }()

  static func platformKey() -> String {
#if os(Windows)
    return "windows"
#elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    return "macos"
#elseif os(Android)
    return "android"
#else
    return "linux"
#endif
  }

  static func parseProperties(at path: String) -> [String: String]? {
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
      return nil
    }
    var result: [String: String] = [:]
    for line in content.components(separatedBy: .newlines) {
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      guard !trimmed.isEmpty, !trimmed.hasPrefix("#"), !trimmed.hasPrefix("!") else { continue }
      guard let eqRange = trimmed.range(of: "=") else { continue }
      let key   = trimmed[trimmed.startIndex..<eqRange.lowerBound].trimmingCharacters(in: .whitespaces)
      let value = trimmed[eqRange.upperBound...].trimmingCharacters(in: .whitespaces)
      if !key.isEmpty { result[key] = value }
    }
    return result.isEmpty ? nil : result
  }
}

// =============================================================================
// MARK: - ServiceLoader
// =============================================================================

extension java.util {

  /// Port of `java.util.ServiceLoader`.
  ///
  /// A facility for loading service providers. A *service* is a well-known
  /// interface or abstract class for which one or more *providers* supply
  /// concrete implementations.
  ///
  /// ## How it works (Swift port)
  ///
  /// Unlike Java's classpath-based discovery, this implementation reads a
  /// `.properties` file per service from a configurable search path.
  ///
  /// **Properties file location** (searched in order):
  /// 1. Environment variable `JAVAPI_SERVICES_PATH`
  /// 2. `./services/` relative to the running executable
  /// 3. `/usr/share/javapi/services/` (Linux/macOS)
  /// 4. `%APPDATA%\JavApi\services\` (Windows)
  ///
  /// **Properties file name:** `<service-interface-name>.properties`
  /// e.g. `java.nio.charset.spi.CharsetProvider.properties`
  ///
  /// **Properties file format:**
  /// ```properties
  /// # Required
  /// library  = mycharsets
  /// provider = MyCharsetProvider_create
  ///
  /// # Optional platform overrides (take precedence over 'library')
  /// library.linux   = libmycharsets.so
  /// library.macos   = libmycharsets.dylib
  /// library.windows = mycharsets.dll
  /// ```
  ///
  /// The `library` value is passed through `_DynamicLoader.canonicalName(_:)`
  /// so bare names like `mycharsets` are expanded to the platform filename.
  ///
  /// **Provider convention** — the factory must be exported as a C symbol
  /// (Swift 6.3 `@c` attribute) with signature:
  /// ```c
  /// void* ProviderName_create(void);
  /// ```
  /// It returns a pointer to a heap-allocated vtable struct.
  /// The caller is responsible for the lifetime of that pointer.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// struct MyServiceVTable {
  ///     let doWork: @convention(c) () -> Void
  /// }
  ///
  /// let loader = java.util.ServiceLoader<MyServiceVTable>(
  ///     serviceName: "com.example.MyService"
  /// )
  /// for vtablePtr in loader {
  ///     vtablePtr.pointee.doWork()
  /// }
  /// ```
  ///
  /// - Since: Java 1.6
  public final class ServiceLoader<VTable>: Sequence, @unchecked Sendable {

    // MARK: - State

    private let serviceName: String
    private var cachedProviders: [UnsafeMutablePointer<VTable>]?

    // MARK: - Init

    /// Creates a `ServiceLoader` that will discover providers for the given
    /// service interface name.
    ///
    /// - Parameter serviceName: Fully-qualified service name, used as the
    ///   base name of the `.properties` file.
    public init(serviceName: String) {
      self.serviceName = serviceName
    }

    // MARK: - Public API

    /// Returns a new loader for the named service.
    /// - Since: Java 1.6
    public static func load(serviceName: String) -> ServiceLoader<VTable> {
      return ServiceLoader<VTable>(serviceName: serviceName)
    }

    /// Clears the cached provider list so the next iteration reloads.
    /// - Since: Java 1.6
    public func reload() {
      cachedProviders = nil
    }

    /// Overrides the global search path list for service `.properties` files.
    ///
    /// Call once at application startup before the first `ServiceLoader` is
    /// created. This is a Swift extension — Java has no equivalent because
    /// it uses the classpath instead.
    ///
    /// - Parameter paths: Ordered list of directory paths to search.
    public static func setSearchPaths(_ paths: [String]) {
      _ServiceLoaderConfig.searchPaths = paths
    }

    // MARK: - Sequence

    public func makeIterator() -> IndexingIterator<[UnsafeMutablePointer<VTable>]> {
      if cachedProviders == nil {
        cachedProviders = loadProviders()
      }
      return (cachedProviders ?? []).makeIterator()
    }

    // MARK: - Internal loading

    private func loadProviders() -> [UnsafeMutablePointer<VTable>] {
      guard let props = findProperties() else { return [] }

      let libraryKey = "library.\(_ServiceLoaderConfig.platformKey())"
      let libraryRaw = (props[libraryKey] ?? props["library"] ?? "")
                         .trimmingCharacters(in: .whitespaces)
      guard !libraryRaw.isEmpty else { return [] }

      let libraryName    = _DynamicLoader.canonicalName(libraryRaw)
      let providerSymbol = (props["provider"] ?? "").trimmingCharacters(in: .whitespaces)
      guard !providerSymbol.isEmpty else { return [] }

      do {
        let loader = try _DynamicLoader(path: libraryName)
        typealias CreateFn = @convention(c) () -> UnsafeMutableRawPointer?
        let create: CreateFn = try loader.symbol(providerSymbol)
        guard let raw = create() else { return [] }
        let typed = raw.bindMemory(to: VTable.self, capacity: 1)
        return [typed]
      } catch {
        // Silent failure — mirrors Java's behaviour where absent providers
        // simply yield no entries.
        return []
      }
    }

    // MARK: - Properties file discovery

    private func findProperties() -> [String: String]? {
      let filename = "\(serviceName).properties"
      for dir in _ServiceLoaderConfig.searchPaths {
        let path = (dir as NSString).appendingPathComponent(filename)
        if let props = _ServiceLoaderConfig.parseProperties(at: path) {
          return props
        }
      }
      return nil
    }
  }
}
