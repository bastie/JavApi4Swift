/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A structural unit within a `Document` — mirrors
  /// `javax.swing.text.Element` from Java 1.2 / JFC 1.0.
  ///
  /// A `Document` is organised as a tree of `Element`s.  Leaf elements
  /// span a range of characters; branch elements contain child elements.
  ///
  /// ## Example tree for a `StyledDocument`
  ///
  /// ```
  /// root (branch)
  ///   paragraph (branch)
  ///     run (leaf, chars 0..5, bold)
  ///     run (leaf, chars 5..10, italic)
  ///   paragraph (branch)
  ///     …
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  public protocol Element: AnyObject {

    // -------------------------------------------------------------------------
    // MARK: Document linkage
    // -------------------------------------------------------------------------

    /// Returns the document this element belongs to.
    func getDocument() -> javax.swing.text.Document

    // -------------------------------------------------------------------------
    // MARK: Tree structure
    // -------------------------------------------------------------------------

    /// Returns the parent element, or `nil` for the root.
    func getParentElement() -> javax.swing.text.Element?

    /// Returns the name of this element (e.g. `"paragraph"`, `"content"`).
    func getName() -> String

    /// Returns the number of child elements (0 for leaf elements).
    func getElementCount() -> Int

    /// Returns the child element at `index`.
    func getElement(_ index: Int) -> javax.swing.text.Element?

    /// Returns the index of the child element that contains `offset`.
    func getElementIndex(_ offset: Int) -> Int

    /// Returns `true` if this is a leaf element (no children).
    func isLeaf() -> Bool

    // -------------------------------------------------------------------------
    // MARK: Character range
    // -------------------------------------------------------------------------

    /// Returns the start offset of this element's content in the document.
    func getStartOffset() -> Int

    /// Returns the end offset (exclusive) of this element's content.
    func getEndOffset() -> Int

    // -------------------------------------------------------------------------
    // MARK: Attributes
    // -------------------------------------------------------------------------

    /// Returns the attributes associated with this element.
    func getAttributes() -> javax.swing.text.AttributeSet
  }
}
