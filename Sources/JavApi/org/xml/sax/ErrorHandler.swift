/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {
  
  /// - Since: SAX 1.0
  @available (*, deprecated, message: "Use SAX2 XMLReader instead")
  public protocol Parser {
    func parse ( _ source : InputSource) throws
    func parse ( _ source : String) throws
    func setErrorHandler ( _ errorHandler : ErrorHandler)
    func setDocumentHandler ( _ documentHandler : DocumentHandler)
    func setDTDHandler ( _ dtdHandler : DTDHandler)
    func setEntityResolver ( _ entityResolver : EntityResolver)
    func setLocale ( _ locale : java.util.Locale)
  }
}
