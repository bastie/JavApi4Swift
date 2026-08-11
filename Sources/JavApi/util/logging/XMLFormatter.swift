/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {

  /// A `Formatter` that encodes log records as XML elements compatible with
  /// `java.util.logging.XMLFormatter` (Java 1.4).
  ///
  /// Each record is wrapped in a `<record>` element.  The document head
  /// (`<?xml … ?>` plus DTD reference) is provided by `getHead` and the
  /// closing `</log>` tag by `getTail`, so that a sequence of records forms a
  /// well-formed XML document when written by the same handler.
  ///
  /// - Since: Java 1.4
  open class XMLFormatter: Formatter {

    public override init() { super.init() }

    open override func getHead(_ handler: Handler?) -> String {
      return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n"
        + "<!DOCTYPE log SYSTEM \"logger.dtd\">\n"
        + "<log>\n"
    }

    open override func getTail(_ handler: Handler?) -> String {
      return "</log>\n"
    }

    open override func format(_ record: LogRecord) -> String {
      var xml = "<record>\n"

      xml += "  <date>\(record.getMillis())</date>\n"
      xml += "  <millis>\(record.getMillis())</millis>\n"
      xml += "  <sequence>\(record.getSequenceNumber())</sequence>\n"

      if let name = record.getLoggerName() {
        xml += "  <logger>\(_escape(name))</logger>\n"
      }

      xml += "  <level>\(_escape(record.getLevel().getName()))</level>\n"

      if let cls = record.getSourceClassName() {
        xml += "  <class>\(_escape(cls))</class>\n"
      }
      if let mth = record.getSourceMethodName() {
        xml += "  <method>\(_escape(mth))</method>\n"
      }

      xml += "  <thread>\(record.getThreadID())</thread>\n"

      if let msg = record.getMessage() {
        xml += "  <message>\(_escape(msg))</message>\n"
      }

      let params = record.getParameters()
      for param in params {
        xml += "  <param>\(_escape("\(param)"))</param>\n"
      }

      if let thrown = record.getThrown() {
        xml += "  <exception>\n"
        xml += "    <message>\(_escape("\(thrown)"))</message>\n"
        xml += "  </exception>\n"
      }

      xml += "</record>\n"
      return xml
    }

    // MARK: - XML escaping

    private func _escape(_ s: String) -> String {
      var result = s
      result = result.replacingOccurrences(of: "&",  with: "&amp;")
      result = result.replacingOccurrences(of: "<",  with: "&lt;")
      result = result.replacingOccurrences(of: ">",  with: "&gt;")
      result = result.replacingOccurrences(of: "\"", with: "&quot;")
      result = result.replacingOccurrences(of: "'",  with: "&apos;")
      return result
    }
  }
}
