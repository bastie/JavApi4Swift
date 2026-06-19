/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// =============================================================================
// MARK: Platform imports
// =============================================================================

#if os(Windows)
import WinSDK
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#else
// Fallback: declare POSIX symbols directly (e.g. static musl)
@_silgen_name("dlopen")
private func dlopen(_ path: UnsafePointer<CChar>?, _ flags: CInt) -> UnsafeMutableRawPointer?
@_silgen_name("dlsym")
private func dlsym(_ handle: UnsafeMutableRawPointer?, _ symbol: UnsafePointer<CChar>) -> UnsafeMutableRawPointer?
@_silgen_name("dlclose")
private func dlclose(_ handle: UnsafeMutableRawPointer?) -> CInt
@_silgen_name("dlerror")
private func dlerror() -> UnsafeMutablePointer<CChar>?
#endif

#if os(Linux) || os(FreeBSD) || os(Android)
private let _RTLD_LAZY: CInt = 0x00001
private let _RTLD_GLOBAL: CInt = 0x00100
#endif

// =============================================================================
// MARK: _DynamicLoader
// =============================================================================

/// Internal plattform-agnostic wrapper around dynamic library loading.
///
/// On POSIX systems (Linux, macOS, Android, FreeBSD) this uses `dlopen` /
/// `dlsym` / `dlclose`. On Windows it uses `LoadLibraryA` / `GetProcAddress`
/// / `FreeLibrary`.
///
/// Provider libraries export a single C factory function whose name is read
/// from the service `.properties` file (`provider` key). The factory returns
/// an `UnsafeMutableRawPointer` that the caller casts to a typed vtable struct.
///
/// **Convention for provider libraries:**
/// ```swift
/// // Swift — use the new @c attribute (Swift 6.3) for stable C export
/// @c(MyService_create)
/// public func myServiceCreate() -> UnsafeMutableRawPointer? {
///     let vtable = UnsafeMutablePointer<MyServiceVTable>.allocate(capacity: 1)
///     vtable.initialize(to: MyServiceVTable(doWork: myDoWork))
///     return UnsafeMutableRawPointer(vtable)
/// }
/// ```
///
/// - Note: This type is intentionally `internal` — it is an implementation
///   detail of `ServiceLoader` and not part of the public JavApi API.
internal final class _DynamicLoader: @unchecked Sendable {

  // MARK: - Platform handle

#if os(Windows)
  private let handle: HMODULE
#else
  private let handle: UnsafeMutableRawPointer
#endif

  // MARK: - Init / deinit

  /// Opens the dynamic library at `path`.
  ///
  /// - Parameter path: Absolute or relative path to the shared library
  ///   (`.so`, `.dylib`, or `.dll`).
  /// - Throws: `UnsatisfiedLinkError` if the library cannot be opened.
  init(path: String) throws {
#if os(Windows)
    guard let h = path.withCString(encodedAs: UTF16.self, LoadLibraryW) else {
      throw _DynamicLoader.linkError("LoadLibraryW failed for '\(path)'")
    }
    self.handle = h
#else
    guard let h = dlopen(path, _RTLD_LAZY | _RTLD_GLOBAL) else {
      let reason = dlerror().map { String(cString: $0) } ?? "unknown error"
      throw _DynamicLoader.linkError("dlopen failed for '\(path)': \(reason)")
    }
    self.handle = h
#endif
  }

  deinit {
#if os(Windows)
    FreeLibrary(handle)
#else
    _ = dlclose(handle)
#endif
  }

  // MARK: - Symbol lookup

  /// Looks up a C symbol by name and returns it as a typed function pointer.
  ///
  /// Usage:
  /// ```swift
  /// typealias CreateFn = @convention(c) () -> UnsafeMutableRawPointer?
  /// let create: CreateFn = try loader.symbol("MyService_create")
  /// ```
  ///
  /// - Parameter name: The exported C symbol name.
  /// - Returns: The symbol cast to `F`.
  /// - Throws: `UnsatisfiedLinkError` if the symbol is not found.
  func symbol<F>(_ name: String) throws -> F {
#if os(Windows)
    guard let ptr = GetProcAddress(handle, name) else {
      throw _DynamicLoader.linkError("symbol '\(name)' not found")
    }
    return unsafeBitCast(ptr, to: F.self)
#else
    guard let ptr = dlsym(handle, name) else {
      let reason = dlerror().map { String(cString: $0) } ?? "unknown error"
      throw _DynamicLoader.linkError("symbol '\(name)' not found: \(reason)")
    }
    return unsafeBitCast(ptr, to: F.self)
#endif
  }

  // MARK: - Platform library name helper

  /// Returns the platform-canonical filename for a library base name.
  ///
  /// Examples:
  /// - `"myservice"` → `"libmyservice.so"` (Linux)
  /// - `"myservice"` → `"libmyservice.dylib"` (macOS)
  /// - `"myservice"` → `"myservice.dll"` (Windows)
  ///
  /// If `name` already contains a path separator or extension it is returned
  /// unchanged, so absolute paths from the `.properties` file always work.
  static func canonicalName(_ name: String) -> String {
    guard !name.contains("/") && !name.contains("\\") && !name.contains(".") else {
      return name
    }
#if os(Windows)
    return "\(name).dll"
#elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    return "lib\(name).dylib"
#else
    return "lib\(name).so"
#endif
  }

  // MARK: - Error helper

  private static func linkError(_ message: String) -> UnsatisfiedLinkError {
    return UnsatisfiedLinkError(message)
  }
}
