/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.net {

  /// Abstract base class for content handlers.
  ///
  /// Java 1.0 `java.net.ContentHandler`. A content handler converts the bytes
  /// received from a URL connection into a Java object of the appropriate type.
  ///
  /// In Java, content handlers are looked up by MIME type and registered via
  /// `URLConnection.setContentHandlerFactory()`. That factory mechanism is not
  /// implemented in JavApi⁴Swift; subclass `ContentHandler` and call
  /// ``getContent(_:)`` directly if custom content parsing is needed.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  open class ContentHandler: @unchecked Sendable {

    public init() {}

    /// Returns the object represented by the URL connection.
    ///
    /// Subclasses must override this method and read from
    /// `connection.getInputStream()` to parse the content.
    ///
    /// - Parameter connection: An open ``URLConnection``.
    /// - Returns: The parsed content object.
    /// - Throws: ``java.io.IOException`` — subclasses must override.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    open func getContent(_ connection: URLConnection) throws -> Any? {
      throw java.io.IOException("ContentHandler.getContent() must be overridden by subclass")
    }
  }
}
