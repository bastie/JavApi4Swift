/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

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
  /// so bare names like `mycharsets` are automatically expanded to the
  /// platform-specific filename.
  ///
  /// **Provider convention** — the factory function must be exported as a C
  /// symbol (use Swift 6.3's `@c` attribute or `@_silgen_name` for older
  /// toolchains) and must match the signature:
  /// ```c
  /// void* ProviderName_create(void);
  /// ```
  /// It returns an `UnsafeMutableRawPointer` to a heap-allocated vtable
  /// struct. The caller is responsible for the lifetime of that pointer.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// // 1. Define the vtable that providers must fill in
  /// struct MyServiceVTable {
  ///     let doWork: @convention(c) () -> Void
  /// }
  ///
  /// // 2. Load all providers for "com.example.MyService"
  /// let loader = java.util.ServiceLoader<MyServiceVTable>(
  ///     serviceName: "com.example.MyService"
  /// )
  ///
  /// // 3. Iterate
  /// for vtablePtr in loader {
  ///     vtablePtr.pointee.doWork()
  /// }
  /// ```
  ///
  /// - Note: `ServiceLoader` is intentionally NOT generic over a Swift
  ///   protocol here because the provider lives in a dynamically loaded
  ///   library and cannot conform to a Swift protocol at compile time.
  ///   The vtable pattern (Option A) is used instead.
  ///
  /// - Since: Java 1.6
  public final class ServiceLoader<VTable>: Sequence, @unchecked Sendable {

    // MARK: - State

    private let serviceName: String
    private var cachedProviders: [UnsafeMutablePointer<VTable>]?
    nonisolated(unsafe) private static var searchPaths: [String] = Self.defaultSearchPaths()

    // MARK: - Init

    /// Creates a `ServiceLoader` that will discover providers for the given
    /// service interface name.
    ///
    /// - Parameter serviceName: Fully-qualified service name, used as the
    ///   base name of the `.properties` file
    ///   (e.g. `"java.nio.charset.spi.CharsetProvider"`).
    public init(serviceName: String) {
      self.serviceName = serviceName
    }

    // MARK: - Public API

    /// Equivalent to `ServiceLoader.load(serviceName:)` — returns a new
    /// loader for the named service.
    ///
    /// - Parameter serviceName: Fully-qualified service interface name.
    /// - Returns: A new `ServiceLoader` instance.
    /// - Since: Java 1.6
    public static func load(serviceName: String) -> ServiceLoader<VTable> {
      return ServiceLoader<VTable>(serviceName: serviceName)
    }

    /// Reloads the provider list on the next iteration.
    ///
    /// Clears the cached provider list so that the next call to the
    /// iterator will reload and reinstantiate the providers.
    ///
    /// - Since: Java 1.6
    public func reload() {
      cachedProviders = nil
    }

    /// Overrides the global search path list for service `.properties` files.
    ///
    /// This is a Swift extension to the Java API, needed because Swift has no
    /// classpath concept.
    ///
    /// - Parameter paths: Ordered list of directory paths to search.
    public static func setSearchPaths(_ paths: [String]) {
      searchPaths = paths
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
      guard let props = findProperties() else {
        return []
      }

      // Resolve library name (platform-specific override wins)
      let libraryKey = "library.\(Self.platformKey())"
      let libraryRaw = props[libraryKey] ?? props["library"] ?? ""
      guard !libraryRaw.isEmpty else { return [] }

      let libraryName = _DynamicLoader.canonicalName(libraryRaw.trimmingCharacters(in: .whitespaces))
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
        // Silent failure — no provider available on this platform/install.
        // Mirrors Java's behaviour where absent providers simply yield no entries.
        return []
      }
    }

    // MARK: - Properties file discovery

    private func findProperties() -> [String: String]? {
      let filename = "\(serviceName).properties"
      for dir in Self.searchPaths {
        let path = (dir as NSString).appendingPathComponent(filename)
        if let props = Self.parseProperties(at: path) {
          return props
        }
      }
      return nil
    }

    /// Parses a Java-style `.properties` file.
    ///
    /// Supports:
    /// - `key = value` and `key=value`
    /// - `#` and `!` line comments
    /// - Blank lines
    private static func parseProperties(at path: String) -> [String: String]? {
      guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return nil
      }
      var result: [String: String] = [:]
      for line in content.components(separatedBy: .newlines) {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("#"), !trimmed.hasPrefix("!") else { continue }
        guard let eqRange = trimmed.range(of: "=") else { continue }
        let key = trimmed[trimmed.startIndex..<eqRange.lowerBound]
          .trimmingCharacters(in: .whitespaces)
        let value = trimmed[eqRange.upperBound...]
          .trimmingCharacters(in: .whitespaces)
        if !key.isEmpty {
          result[key] = value
        }
      }
      return result.isEmpty ? nil : result
    }

    // MARK: - Platform helpers

    private static func platformKey() -> String {
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

    private static func defaultSearchPaths() -> [String] {
      var paths: [String] = []

      // 1. Environment variable
      if let envPath = ProcessInfo.processInfo.environment["JAVAPI_SERVICES_PATH"] {
        paths.append(contentsOf: envPath.components(separatedBy: ":"))
      }

      // 2. Next to the executable
      if let execURL = Bundle.main.executableURL {
        paths.append(execURL.deletingLastPathComponent().appendingPathComponent("services").path)
      }

      // 3. Platform system paths
#if os(Windows)
      if let appData = ProcessInfo.processInfo.environment["APPDATA"] {
        paths.append((appData as NSString).appendingPathComponent("JavApi\\services"))
      }
#else
      paths.append("/usr/share/javapi/services")
#endif

      return paths
    }
  }
}
