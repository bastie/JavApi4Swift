/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A multi-line plain-text editing area — mirrors `javax.swing.JTextArea`.
  ///
  /// `JTextArea` extends `JTextComponent` and adds:
  /// - **rows / columns** hints that drive the preferred size.
  /// - **Line-wrap** control (`lineWrap`, `wrapStyleWord`).
  /// - Per-line access: `getLineCount()`, `getLineOfOffset(_:)`,
  ///   `getLineStartOffset(_:)`, `getLineEndOffset(_:)`.
  /// - `append(_:)` and `insert(_:at:)` convenience methods.
  ///
  /// `JTextArea` is typically wrapped in a `JScrollPane` to provide
  /// scrolling when content exceeds the visible area:
  ///
  /// ```swift
  /// let area   = javax.swing.JTextArea("Insert notes here…", 4, 20)
  /// area.setLineWrap(true)
  /// area.setWrapStyleWord(true)
  /// let scroll = javax.swing.JScrollPane(area)
  /// panel.add(scroll)
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JTextArea: javax.swing.text.JTextComponent {

    // -------------------------------------------------------------------------
    // MARK: Rows / columns
    // -------------------------------------------------------------------------

    private var _rows:    Int
    private var _columns: Int

    /// The number of visible rows used to calculate the preferred height.
    public func getRows() -> Int { _rows }
    public func setRows(_ rows: Int) { _rows = max(0, rows); invalidate() }

    /// The number of visible columns used to calculate the preferred width.
    public func getColumns() -> Int { _columns }
    public func setColumns(_ columns: Int) { _columns = max(0, columns); invalidate() }

    // -------------------------------------------------------------------------
    // MARK: Line wrap
    // -------------------------------------------------------------------------

    private var _lineWrap:      Bool = false
    private var _wrapStyleWord: Bool = false

    /// Whether lines are wrapped when they exceed the component width.
    public func getLineWrap() -> Bool { _lineWrap }
    public func setLineWrap(_ wrap: Bool) { _lineWrap = wrap; invalidate() }

    /// When `lineWrap` is `true`, whether wrapping occurs at word boundaries.
    public func getWrapStyleWord() -> Bool { _wrapStyleWord }
    public func setWrapStyleWord(_ word: Bool) { _wrapStyleWord = word; invalidate() }

    // -------------------------------------------------------------------------
    // MARK: Tab size
    // -------------------------------------------------------------------------

    private var _tabSize: Int = 8

    /// The number of characters a tab stop is equivalent to (default: 8).
    public func getTabSize() -> Int { _tabSize }
    public func setTabSize(_ size: Int) { _tabSize = max(1, size) }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates an empty text area with no size hint.
    public override init() {
      _rows    = 0
      _columns = 0
      super.init()
      updateUI()
    }

    /// Creates a text area with initial text.
    public init(_ text: String) {
      _rows    = 0
      _columns = 0
      super.init()
      setText(text)
      updateUI()
    }

    /// Creates an empty text area with row and column hints.
    public init(_ rows: Int, _ columns: Int) {
      _rows    = max(0, rows)
      _columns = max(0, columns)
      super.init()
      updateUI()
    }

    /// Creates a text area with initial text and size hints.
    public init(_ text: String, _ rows: Int, _ columns: Int) {
      _rows    = max(0, rows)
      _columns = max(0, columns)
      super.init()
      setText(text)
      updateUI()
    }

    /// Creates a text area backed by the given document model.
    public init(document: javax.swing.text.Document, _ text: String, _ rows: Int, _ columns: Int) {
      _rows    = max(0, rows)
      _columns = max(0, columns)
      super.init(document: document)
      setText(text)
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "TextAreaUI" }

    // -------------------------------------------------------------------------
    // MARK: Convenience mutation
    // -------------------------------------------------------------------------

    /// Appends `text` to the end of the document.
    public func append(_ text: String) {
      let len = getDocument().getLength()
      try? getDocument().insertString(len, text)
    }

    /// Inserts `text` at the given character `offset`.
    ///
    /// - Parameters:
    ///   - text: The string to insert.
    ///   - offset: Zero-based character position.
    public func insert(_ text: String, _ offset: Int) {
      try? getDocument().insertString(offset, text)
    }

    /// Replaces the text in `[start, end)` with `text`.
    public func replaceRange(_ text: String, _ start: Int, _ end: Int) {
      let length = end - start
      guard length >= 0 else { return }
      do {
        if length > 0 { try getDocument().remove(start, length) }
        if !text.isEmpty { try getDocument().insertString(start, text) }
      } catch {}
    }

    // -------------------------------------------------------------------------
    // MARK: Line utilities
    // -------------------------------------------------------------------------

    /// Returns the number of lines in the document (at least 1).
    public func getLineCount() -> Int {
      let content = getText()
      guard !content.isEmpty else { return 1 }
      return content.components(separatedBy: "\n").count
    }

    /// Returns the zero-based line number that contains `offset`.
    ///
    /// - Throws: `BadLocationException` if `offset` is out of range.
    public func getLineOfOffset(_ offset: Int) throws -> Int {
      let len = getDocument().getLength()
      guard offset >= 0, offset <= len else {
        throw javax.swing.text.BadLocationException(
          "getLineOfOffset: offset=\(offset) docLength=\(len)", offset)
      }
      let content = getText()
      let idx     = content.index(content.startIndex, offsetBy: offset)
      let before  = content[content.startIndex..<idx]
      return before.components(separatedBy: "\n").count - 1
    }

    /// Returns the start offset of the given zero-based `line`.
    ///
    /// - Throws: `BadLocationException` if `line` is out of range.
    public func getLineStartOffset(_ line: Int) throws -> Int {
      let content = getText()
      let lines   = content.components(separatedBy: "\n")
      guard line >= 0, line < lines.count else {
        throw javax.swing.text.BadLocationException(
          "getLineStartOffset: line=\(line) lineCount=\(lines.count)", 0)
      }
      return lines[0..<line].reduce(0) { $0 + $1.count + 1 }
    }

    /// Returns the end offset of the given zero-based `line` (points past the newline).
    ///
    /// - Throws: `BadLocationException` if `line` is out of range.
    public func getLineEndOffset(_ line: Int) throws -> Int {
      let start = try getLineStartOffset(line)
      let lines = getText().components(separatedBy: "\n")
      return start + lines[line].count + (line < lines.count - 1 ? 1 : 0)
    }
  }
}
