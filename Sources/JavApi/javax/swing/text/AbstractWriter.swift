/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// Abstract base class for document serializers — mirrors
  /// `javax.swing.text.AbstractWriter` from Java 1.2 / JFC 1.0.
  ///
  /// `AbstractWriter` provides helper infrastructure for writing the content of
  /// a `Document` (or a sub-range of it) to a `java.io.Writer`-like output.
  /// Concrete subclasses (e.g. `HTMLWriter`, `MinimalHTMLWriter`) override
  /// `write()` and use the protected helpers to emit text.
  ///
  /// In JavApi⁴Swift output is written into a Swift `String` accumulator
  /// instead of a `java.io.Writer`.  Call `output` after `write()` to retrieve
  /// the result.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// class MyWriter: javax.swing.text.AbstractWriter {
  ///   override func write() throws {
  ///     try writeStartTag("<doc>")
  ///     try text()
  ///     try writeEndTag("</doc>")
  ///   }
  /// }
  /// let w = MyWriter(doc: myDoc)
  /// try w.write()
  /// print(w.output)
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class AbstractWriter {

    // -------------------------------------------------------------------------
    // MARK: Constants
    // -------------------------------------------------------------------------

    /// The system line separator (UNIX `\n` in JavApi⁴Swift).
    public static let NEWLINE: Character = "\n"

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private let _doc:         javax.swing.text.Document
    private let _startOffset: Int
    private let _endOffset:   Int

    /// The accumulated output string — read this after calling `write()`.
    public private(set) var output: String = ""

    /// Current indentation level (number of `indentSize` spaces).
    private var _indentLevel: Int = 0

    /// Number of spaces per indent level (default 4, same as Java).
    private var _indentSize:  Int = 4

    /// Line-length limit for word-wrapping (default 100, same as Java).
    private var _lineLength:  Int = 100

    /// Characters written on the current line (for line-wrap tracking).
    private var _currentLineLength: Int = 0

    /// Whether the writer is at the start of a new line.
    private var _atLineStart: Bool = true

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates a writer for the entire document.
    public init(doc: javax.swing.text.Document) {
      _doc         = doc
      _startOffset = 0
      _endOffset   = doc.getLength()
    }

    /// Creates a writer for the sub-range `[pos, pos+len)`.
    public init(doc: javax.swing.text.Document, pos: Int, len: Int) {
      _doc         = doc
      _startOffset = pos
      _endOffset   = pos + len
    }

    /// Creates a writer starting from a specific `Element`.
    public init(doc: javax.swing.text.Document, element: javax.swing.text.Element) {
      _doc         = doc
      _startOffset = element.getStartOffset()
      _endOffset   = element.getEndOffset()
    }

    // -------------------------------------------------------------------------
    // MARK: Abstract method — subclasses must override
    // -------------------------------------------------------------------------

    /// Writes the document content to `output`.
    ///
    /// Subclasses override this method and use the protected helpers
    /// (`write(_:)`, `indent()`, `writeLineSeparator()`, etc.) to emit text.
    ///
    /// - Throws: Any error encountered during writing.
    open func write() throws {
      fatalError("\(type(of: self)).write() must be overridden")
    }

    // -------------------------------------------------------------------------
    // MARK: Document / range accessors
    // -------------------------------------------------------------------------

    /// Returns the document being written.
    public func getDocument() -> javax.swing.text.Document { _doc }

    /// Returns the start offset of the range being written.
    public func getStartOffset() -> Int { _startOffset }

    /// Returns the end offset (exclusive) of the range being written.
    public func getEndOffset() -> Int { _endOffset }

    // -------------------------------------------------------------------------
    // MARK: Indent control
    // -------------------------------------------------------------------------

    /// Returns the current indent level.
    public func getIndentLevel() -> Int { _indentLevel }

    /// Increments the indent level by one.
    public func incrIndent() { _indentLevel += 1 }

    /// Decrements the indent level by one (minimum 0).
    public func decrIndent() { if _indentLevel > 0 { _indentLevel -= 1 } }

    /// Returns the number of spaces per indent level.
    public func getIndentSpace() -> Int { _indentSize }

    /// Sets the number of spaces per indent level.
    public func setIndentSpace(_ space: Int) { _indentSize = max(0, space) }

    /// Returns the line-length limit.
    public func getLineLength() -> Int { _lineLength }

    /// Sets the line-length limit.
    public func setLineLength(_ l: Int) { _lineLength = max(1, l) }

    /// Returns the number of characters written on the current line.
    public func getCurrentLineLength() -> Int { _currentLineLength }

    /// Returns `true` if we are at the start of a new line.
    public func isLineEmpty() -> Bool { _atLineStart }

    // -------------------------------------------------------------------------
    // MARK: Output helpers
    // -------------------------------------------------------------------------

    /// Writes the current indentation (spaces) to the output.
    public func indent() throws {
      let spaces = String(repeating: " ", count: _indentLevel * _indentSize)
      try write(spaces)
    }

    /// Writes a line separator and resets the line-length counter.
    public func writeLineSeparator() throws {
      output.append(Self.NEWLINE)
      _currentLineLength = 0
      _atLineStart       = true
    }

    /// Writes `str` verbatim to the output accumulator.
    public func write(_ str: String) throws {
      output.append(str)
      _currentLineLength += str.count
      if !str.isEmpty { _atLineStart = false }
    }

    /// Writes a single character to the output accumulator.
    public func write(_ ch: Character) throws {
      output.append(ch)
      _currentLineLength += 1
      _atLineStart = false
    }

    /// Writes the text content of `[startOffset, endOffset)` from the document.
    public func text() throws {
      let len = _endOffset - _startOffset
      guard len > 0 else { return }
      let str = try _doc.getText(_startOffset, len)
      try write(str)
    }

    /// Writes an opening tag string (e.g. `"<p>"`).
    public func writeStartTag(_ tag: String) throws {
      try write(tag)
    }

    /// Writes a closing tag string (e.g. `"</p>"`).
    public func writeEndTag(_ tag: String) throws {
      try write(tag)
    }

    /// Writes an attribute value as `" name=\"value\""`.
    public func writeAttribute(_ name: String, _ value: String) throws {
      try write(" \(name)=\"\(value)\"")
    }
  }
}
