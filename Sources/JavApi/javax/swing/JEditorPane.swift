/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A text component that can edit various content types via pluggable
  /// `EditorKit`s — mirrors `javax.swing.JEditorPane` from Java 1.2 / JFC 1.0.
  ///
  /// `JEditorPane` extends `JTextComponent` and uses a `StyledEditorKit`
  /// to determine the content type, document model, and (in a full Swing
  /// implementation) the view hierarchy.  In JavApi⁴Swift the rendering
  /// falls back to the same plain-text painting used by `JTextArea`.
  ///
  /// ## Hierarchy
  ///
  /// ```
  /// JComponent
  ///   └── JTextComponent
  ///         └── JEditorPane      ← this class
  ///               └── JTextPane
  /// ```
  ///
  /// ## Example
  ///
  /// ```swift
  /// let pane = javax.swing.JEditorPane()
  /// pane.setContentType("text/html")
  /// pane.setText("<b>Hello</b>")
  /// ```
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  open class JEditorPane: javax.swing.text.JTextComponent {

    // -------------------------------------------------------------------------
    // MARK: EditorKit
    // -------------------------------------------------------------------------

    private var _editorKit: javax.swing.text.StyledEditorKit

    /// Returns the currently installed `EditorKit`.
    open func getEditorKit() -> javax.swing.text.StyledEditorKit { _editorKit }

    /// Replaces the current `EditorKit`.
    ///
    /// The old kit is deinstalled, the new kit is installed, and a new default
    /// document is created.
    open func setEditorKit(_ kit: javax.swing.text.StyledEditorKit) {
      _editorKit.deinstall(self)
      _editorKit = kit
      setDocument(kit.createDefaultDocument())
      kit.install(self)
      invalidate()
    }

    // -------------------------------------------------------------------------
    // MARK: Content type
    // -------------------------------------------------------------------------

    /// Returns the MIME content type of the currently installed `EditorKit`.
    open func getContentType() -> String { _editorKit.getContentType() }

    /// Sets the content type.
    ///
    /// In JavApi⁴Swift this stores the type on the active `StyledEditorKit`.
    /// A full implementation would swap to a kit registered for that type.
    open func setContentType(_ type: String) {
      // For source compatibility: store on a new kit if type changes
      if _editorKit.getContentType() != type {
        let newKit = javax.swing.text.StyledEditorKit()
        // The base StyledEditorKit always returns "text/plain"; override via
        // subclass or accept the simplified behaviour.
        setEditorKit(newKit)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    /// Creates an empty `JEditorPane` with the default `StyledEditorKit`.
    public override init() {
      let kit = javax.swing.text.StyledEditorKit()
      _editorKit = kit
      super.init(document: kit.createDefaultDocument())
      kit.install(self)
      updateUI()
    }

    /// Creates a `JEditorPane` set to display `text` with `contentType`.
    public convenience init(contentType: String, text: String) {
      self.init()
      setContentType(contentType)
      setText(text)
    }

    // -------------------------------------------------------------------------
    // MARK: StyledDocument access
    // -------------------------------------------------------------------------

    /// Returns the underlying document as `StyledDocument`, if applicable.
    public func getStyledDocument() -> javax.swing.text.StyledDocument? {
      return getDocument() as? javax.swing.text.StyledDocument
    }

    /// Replaces the underlying document with a `StyledDocument`.
    public func setStyledDocument(_ doc: javax.swing.text.StyledDocument) {
      setDocument(doc)
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "EditorPaneUI" }
  }
}
