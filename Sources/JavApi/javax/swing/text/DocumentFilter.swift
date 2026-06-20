/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A filter that intercepts mutations to a `Document` before they are applied.
  ///
  /// Install a `DocumentFilter` on an `AbstractDocument` via
  /// `setDocumentFilter(_:)` to validate or transform text before it is
  /// inserted into or removed from the document.
  ///
  /// Each method receives a `FilterBypass` that bypasses the filter and
  /// applies the mutation directly.  A filter implementation must eventually
  /// call one of the bypass methods (possibly with modified arguments) to
  /// allow the document to be changed.  If the filter does not call the
  /// bypass, the mutation is silently discarded.
  ///
  /// ## Example — digits only
  ///
  /// ```swift
  /// class DigitsOnlyFilter: javax.swing.text.DocumentFilter {
  ///   override func insertString(
  ///     _ fb: javax.swing.text.DocumentFilter.FilterBypass,
  ///     _ offset: Int,
  ///     _ string: String
  ///   ) throws {
  ///     let digits = string.filter(\.isNumber)
  ///     try super.insertString(fb, offset, digits)
  ///   }
  ///
  ///   override func replace(
  ///     _ fb: javax.swing.text.DocumentFilter.FilterBypass,
  ///     _ offset: Int,
  ///     _ length: Int,
  ///     _ text: String
  ///   ) throws {
  ///     let digits = text.filter(\.isNumber)
  ///     try super.replace(fb, offset, length, digits)
  ///   }
  /// }
  /// ```
  ///
  /// Mirrors `javax.swing.text.DocumentFilter`.
  ///
  /// - Since: Java 1.4
  @MainActor
  open class DocumentFilter {

    // -------------------------------------------------------------------------
    // MARK: FilterBypass
    // -------------------------------------------------------------------------

    /// Provides direct, unfiltered access to a `Document`'s mutation methods.
    ///
    /// A `FilterBypass` instance is passed to each `DocumentFilter` method.
    /// Calling a bypass method applies the mutation without re-entering the
    /// filter, preventing infinite recursion.
    ///
    /// Mirrors `javax.swing.text.DocumentFilter.FilterBypass`.
    @MainActor
    open class FilterBypass {

      /// The document being mutated.
      open var document: javax.swing.text.Document {
        fatalError("Subclasses of FilterBypass must override `document`")
      }

      /// Inserts `string` into the document at `offset`, bypassing any filter.
      open func insertString(_ offset: Int, _ string: String) throws {
        fatalError("Subclasses of FilterBypass must override insertString(_:_:)")
      }

      /// Removes `length` characters starting at `offset`, bypassing any filter.
      open func remove(_ offset: Int, _ length: Int) throws {
        fatalError("Subclasses of FilterBypass must override remove(_:_:)")
      }

      /// Replaces `length` characters at `offset` with `text`, bypassing any filter.
      open func replace(_ offset: Int, _ length: Int, _ text: String) throws {
        fatalError("Subclasses of FilterBypass must override replace(_:_:_:)")
      }

      public init() {}
    }

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Filter methods
    // -------------------------------------------------------------------------

    /// Called before characters are removed from the document.
    ///
    /// The default implementation delegates directly to `fb.remove(_:_:)`.
    ///
    /// - Parameters:
    ///   - fb: Bypass to apply the remove without re-entering the filter.
    ///   - offset: Start of the range to remove.
    ///   - length: Number of characters to remove.
    open func remove(
      _ fb: FilterBypass,
      _ offset: Int,
      _ length: Int
    ) throws {
      try fb.remove(offset, length)
    }

    /// Called before a string is inserted into the document.
    ///
    /// The default implementation delegates directly to `fb.insertString(_:_:)`.
    ///
    /// - Parameters:
    ///   - fb: Bypass to apply the insert without re-entering the filter.
    ///   - offset: Insertion point.
    ///   - string: Text to insert.
    open func insertString(
      _ fb: FilterBypass,
      _ offset: Int,
      _ string: String
    ) throws {
      try fb.insertString(offset, string)
    }

    /// Called before a range of text is replaced.
    ///
    /// The default implementation delegates directly to `fb.replace(_:_:_:)`.
    ///
    /// - Parameters:
    ///   - fb: Bypass to apply the replacement without re-entering the filter.
    ///   - offset: Start of the range to replace.
    ///   - length: Number of characters to replace.
    ///   - text: Replacement text.
    open func replace(
      _ fb: FilterBypass,
      _ offset: Int,
      _ length: Int,
      _ text: String
    ) throws {
      try fb.replace(offset, length, text)
    }
  }
}
