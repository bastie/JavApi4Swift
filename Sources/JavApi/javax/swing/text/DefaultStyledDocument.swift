/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A concrete `StyledDocument` backed by a plain `String` with a
  /// parallel array of per-character `SimpleAttributeSet`s.
  ///
  /// `DefaultStyledDocument` is the default model used by `JTextPane`.
  ///
  /// ## Storage model
  ///
  /// Internally the document keeps:
  /// - `_content`: the raw text as a Swift `String`.
  /// - `_charAttrs`: one `SimpleAttributeSet` per character index.
  /// - `_paraAttrs`: one `SimpleAttributeSet` per paragraph (separated by `\n`).
  ///
  /// This is a simplified model compared to Java's segment-tree approach but
  /// is sufficient for the JavApi4Swift use case.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class DefaultStyledDocument: javax.swing.text.AbstractDocument,
                                    javax.swing.text.StyledDocument {

    // -------------------------------------------------------------------------
    // MARK: Storage
    // -------------------------------------------------------------------------

    private var _content: String = ""

    /// Per-character attribute sets (index aligned to _content.unicodeScalars).
    private var _charAttrs: [javax.swing.text.SimpleAttributeSet] = []

    /// Per-paragraph attribute sets.  Index 0 covers up to the first '\n', etc.
    private var _paraAttrs: [javax.swing.text.SimpleAttributeSet] = [
      javax.swing.text.SimpleAttributeSet()
    ]

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
    }

    // -------------------------------------------------------------------------
    // MARK: Document — length & text
    // -------------------------------------------------------------------------

    override open func getLength() -> Int { _content.count }

    override open func getText(_ offset: Int, _ length: Int) throws -> String {
      guard offset >= 0, length >= 0, offset + length <= _content.count else {
        throw javax.swing.text.BadLocationException(
          "getText: offset=\(offset) length=\(length) docLength=\(_content.count)", offset)
      }
      let start = _content.index(_content.startIndex, offsetBy: offset)
      let end   = _content.index(start, offsetBy: length)
      return String(_content[start..<end])
    }

    // -------------------------------------------------------------------------
    // MARK: Document — mutation
    // -------------------------------------------------------------------------

    override open func insertString(_ offset: Int, _ string: String) throws {
      try _insertStyled(offset, string, nil)
    }

    /// `StyledDocument` protocol conformance — inserts with attributes, errors silently dropped.
    public func insertString(_ offset: Int,
                             _ string: String,
                             _ attrs: javax.swing.text.AttributeSet?) {
      try? _insertStyled(offset, string, attrs)
    }

    /// Internal throwing implementation shared by both `insertString` overloads.
    private func _insertStyled(_ offset: Int,
                               _ string: String,
                               _ attrs: javax.swing.text.AttributeSet?) throws {
      guard offset >= 0, offset <= _content.count else {
        throw javax.swing.text.BadLocationException(
          "insertString: offset=\(offset) docLength=\(_content.count)", offset)
      }
      let idx = _content.index(_content.startIndex, offsetBy: offset)
      _content.insert(contentsOf: string, at: idx)

      // Insert character attributes for each new character.
      // Copy supplied attrs; fall back to empty defaults.
      let newAttrs = (0..<string.count).map { _ -> javax.swing.text.SimpleAttributeSet in
        if let a = attrs {
          return javax.swing.text.SimpleAttributeSet(copying: a)
        }
        return javax.swing.text.SimpleAttributeSet()
      }
      _charAttrs.insert(contentsOf: newAttrs, at: offset)

      _syncParagraphAttrs()
      fireInsertUpdate(offset: offset, length: string.count)
    }

    override open func remove(_ offset: Int, _ length: Int) throws {
      guard offset >= 0, length >= 0, offset + length <= _content.count else {
        throw javax.swing.text.BadLocationException(
          "remove: offset=\(offset) length=\(length) docLength=\(_content.count)", offset)
      }
      guard length > 0 else { return }
      let start = _content.index(_content.startIndex, offsetBy: offset)
      let end   = _content.index(start, offsetBy: length)
      _content.removeSubrange(start..<end)
      _charAttrs.removeSubrange(offset..<(offset + length))

      _syncParagraphAttrs()
      fireRemoveUpdate(offset: offset, length: length)
    }

    // -------------------------------------------------------------------------
    // MARK: StyledDocument — character attributes
    // -------------------------------------------------------------------------

    open func setCharacterAttributes(_ offset: Int,
                                     _ length: Int,
                                     _ attrs: javax.swing.text.AttributeSet,
                                     _ replace: Bool) {
      let end = min(offset + length, _charAttrs.count)
      guard offset >= 0, offset < end else { return }
      for i in offset..<end {
        if replace {
          _charAttrs[i] = javax.swing.text.SimpleAttributeSet(copying: attrs)
        } else {
          _charAttrs[i].addAttributes(attrs)
        }
      }
      fireChangedUpdate(offset: offset, length: end - offset)
    }

    open func getCharacterElement(_ position: Int) -> javax.swing.text.AttributeSet? {
      guard position >= 0, position < _charAttrs.count else { return nil }
      return _charAttrs[position]
    }

    // -------------------------------------------------------------------------
    // MARK: StyledDocument — paragraph attributes
    // -------------------------------------------------------------------------

    open func setParagraphAttributes(_ offset: Int,
                                     _ length: Int,
                                     _ attrs: javax.swing.text.AttributeSet,
                                     _ replace: Bool) {
      let paraRange = _paragraphIndices(for: offset, length: length)
      for i in paraRange {
        guard i < _paraAttrs.count else { break }
        if replace {
          _paraAttrs[i] = javax.swing.text.SimpleAttributeSet(copying: attrs)
        } else {
          _paraAttrs[i].addAttributes(attrs)
        }
      }
    }

    open func getParagraphElement(_ position: Int) -> javax.swing.text.AttributeSet? {
      let idx = _paragraphIndex(for: position)
      guard idx < _paraAttrs.count else { return nil }
      return _paraAttrs[idx]
    }

    // -------------------------------------------------------------------------
    // MARK: StyledDocument — color convenience
    // -------------------------------------------------------------------------

    open func getForeground(_ attr: javax.swing.text.AttributeSet) -> java.awt.Color {
      return javax.swing.text.StyleConstants.getForeground(attr)
    }

    open func getBackground(_ attr: javax.swing.text.AttributeSet) -> java.awt.Color {
      return javax.swing.text.StyleConstants.getBackground(attr)
    }

    // -------------------------------------------------------------------------
    // MARK: Convenience
    // -------------------------------------------------------------------------

    /// Returns the entire document content as a `String`.
    open func getText() -> String { _content }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    /// Returns the paragraph index (0-based) that contains `position`.
    private func _paragraphIndex(for position: Int) -> Int {
      var idx = 0
      var charCount = 0
      for ch in _content {
        if charCount == position { return idx }
        if ch == "\n" { idx += 1 }
        charCount += 1
      }
      return idx
    }

    /// Returns the range of paragraph indices overlapping `[offset, offset+length)`.
    private func _paragraphIndices(for offset: Int, length: Int) -> Range<Int> {
      let startPara = _paragraphIndex(for: offset)
      let endPara   = _paragraphIndex(for: max(0, offset + length - 1))
      return startPara..<(endPara + 1)
    }

    /// Ensures `_paraAttrs` has exactly as many entries as there are paragraphs.
    private func _syncParagraphAttrs() {
      let paraCount = _content.filter { $0 == "\n" }.count + 1
      while _paraAttrs.count < paraCount {
        _paraAttrs.append(javax.swing.text.SimpleAttributeSet())
      }
      while _paraAttrs.count > paraCount {
        _paraAttrs.removeLast()
      }
    }
  }
}
