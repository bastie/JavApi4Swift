/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {
  
  /// - Since: SAX 1.0
  public protocol DTDHandler {
    func notationDecl(name: String, publicId: String?, systemId: String?)
    func unparsedEntityDecl(name: String, publicId: String?, systemId: String?, notationName: String?)
  }
}
