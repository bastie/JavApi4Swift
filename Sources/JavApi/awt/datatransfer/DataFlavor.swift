/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.datatransfer {

  /// A `DataFlavor` provides meta information about a piece of data.
  ///
  /// Mirrors `java.awt.datatransfer.DataFlavor` (Java 1.1).
  ///
  /// Each flavor is identified by its MIME type string. The two most common
  /// flavors are provided as static constants:
  ///
  /// - ``stringFlavor`` — plain Unicode text as a `String`
  /// - ``plainTextFlavor`` — `text/plain` stream (deprecated in Java, kept for
  ///   compatibility)
  ///
  /// - Since: JavaApi (Java 1.1)
  public final class DataFlavor: Equatable, @unchecked Sendable {

    // MARK: - Well-known flavors

    /// The `DataFlavor` for plain Unicode `String` objects.
    ///
    /// MIME type: `application/x-java-serialized-object; class=java.lang.String`
    public static let stringFlavor = DataFlavor(
      mimeType: "application/x-java-serialized-object; class=java.lang.String",
      humanPresentableName: "Unicode String"
    )

    /// The `DataFlavor` for plain text (deprecated in Java 1.3, kept for API
    /// compatibility).
    ///
    /// MIME type: `text/plain; charset=unicode`
    @available(*, deprecated, renamed: "stringFlavor",
               message: "Use stringFlavor for text transfers")
    public static let plainTextFlavor = DataFlavor(
      mimeType: "text/plain; charset=unicode",
      humanPresentableName: "Plain Text"
    )

    // MARK: - Stored properties

    private let mimeType: String
    private let humanPresentableName: String

    // MARK: - Initialisers

    /// Creates a `DataFlavor` with the given MIME type and human-readable name.
    public init(mimeType: String, humanPresentableName: String) {
      self.mimeType = mimeType
      self.humanPresentableName = humanPresentableName
    }

    /// Creates a `DataFlavor` with the given MIME type.
    /// The human-presentable name defaults to the MIME type string.
    public convenience init(mimeType: String) {
      self.init(mimeType: mimeType, humanPresentableName: mimeType)
    }

    // MARK: - Public API

    /// Returns the MIME type string for this `DataFlavor`.
    public func getMimeType() -> String { mimeType }

    /// Returns the human presentable name for this `DataFlavor`.
    public func getHumanPresentableName() -> String { humanPresentableName }

    /// Returns `true` if the MIME type of this flavor is equal (ignoring
    /// parameters) to the given MIME type string.
    public func isMimeTypeEqual(_ mimeTypeStr: String) -> Bool {
      // Strip parameters before comparing, e.g. "text/plain; charset=unicode" → "text/plain"
      let base = { (s: String) -> String in
        s.split(separator: ";").first.map(String.init)?.trimmingCharacters(in: .whitespaces) ?? s
      }
      return base(mimeType).lowercased() == base(mimeTypeStr).lowercased()
    }

    /// Returns `true` if this `DataFlavor` is equal to another `DataFlavor`.
    public func equals(_ other: DataFlavor) -> Bool { self == other }

    // MARK: - Equatable

    public static func == (lhs: DataFlavor, rhs: DataFlavor) -> Bool {
      lhs.mimeType.lowercased() == rhs.mimeType.lowercased()
    }
  }
}
