/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {

  /// Interface for an XML filter — an ``XMLReader`` that wraps another ``XMLReader``.
  ///
  /// An `XMLFilter` sits between the application and the actual parser.
  /// It receives XML events from the parent reader and can pass them through
  /// unchanged or transform them before forwarding to the application handlers.
  ///
  /// Use ``org.xml.sax.helper.XMLFilterImpl`` as a convenient base class that
  /// forwards all events transparently.
  ///
  /// - Since: Java 1.4
  /// - Since: SAX 2.0
  public protocol XMLFilter : XMLReader {

    /// Sets the parent reader that this filter wraps.
    func setParent(_ parent: (any XMLReader)?)

    /// Returns the parent reader, or `nil` if none has been set.
    func getParent() -> (any XMLReader)?
  }
}
