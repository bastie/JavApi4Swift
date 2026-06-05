/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.net {

  /// Interface for content handler factories.
  ///
  /// Java 1.0 `java.net.ContentHandlerFactory`. Implement this protocol and
  /// register the factory via ``URLConnection/setContentHandlerFactory(_:)`` to
  /// provide custom ``ContentHandler`` instances for specific MIME types.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public protocol ContentHandlerFactory: Sendable {

    /// Returns a `ContentHandler` for the given MIME type, or `nil` if this
    /// factory does not handle that type.
    ///
    /// - Parameter mimetype: A MIME type string such as `"text/html"`.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    func createContentHandler(_ mimetype: String) -> ContentHandler?
  }
}
