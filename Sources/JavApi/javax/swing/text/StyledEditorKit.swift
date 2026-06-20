/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// An `EditorKit` for editing styled text — mirrors
  /// `javax.swing.text.StyledEditorKit` from Java 1.2 / JFC 1.0.
  ///
  /// `StyledEditorKit` provides a `DefaultStyledDocument` as its default
  /// document and carries the current character and paragraph input attributes
  /// that are applied when the user types new text.
  ///
  /// In JavApi⁴Swift this is a lightweight implementation: it creates and
  /// owns the document model and exposes the input-attribute API.
  /// The actual rendering is handled by `BasicTextPaneUI` rather than a
  /// full `ViewFactory` hierarchy.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let kit = javax.swing.text.StyledEditorKit()
  /// let doc = kit.createDefaultDocument() as! javax.swing.text.DefaultStyledDocument
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class StyledEditorKit {

    // -------------------------------------------------------------------------
    // MARK: Input attributes
    // -------------------------------------------------------------------------

    /// The character attributes that will be applied to newly typed text.
    private var _inputAttributes: javax.swing.text.MutableAttributeSet =
      javax.swing.text.SimpleAttributeSet()

    /// Returns the character attributes applied to newly typed text.
    open func getInputAttributes() -> javax.swing.text.MutableAttributeSet {
      _inputAttributes
    }

    // -------------------------------------------------------------------------
    // MARK: Document factory
    // -------------------------------------------------------------------------

    /// Creates and returns a new `DefaultStyledDocument`.
    open func createDefaultDocument() -> javax.swing.text.Document {
      javax.swing.text.DefaultStyledDocument()
    }

    // -------------------------------------------------------------------------
    // MARK: Content type
    // -------------------------------------------------------------------------

    /// Returns the MIME content type this kit handles.
    ///
    /// The base `StyledEditorKit` returns `"text/plain"`.
    /// Subclasses (e.g. an HTML kit) override this.
    open func getContentType() -> String { "text/plain" }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Install / deinstall
    // -------------------------------------------------------------------------

    /// Called when this kit is installed into a `JEditorPane`.
    open func install(_ c: javax.swing.JComponent) {
      // Default: no-op. Subclasses can set up listeners here.
    }

    /// Called when this kit is removed from a `JEditorPane`.
    open func deinstall(_ c: javax.swing.JComponent) {
      // Default: no-op.
    }
  }
}
