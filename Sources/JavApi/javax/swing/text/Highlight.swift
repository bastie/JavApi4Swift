/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// An installed highlight — mirrors `Highlighter.Highlight`
  /// from Java 1.2 / JFC 1.0.
  ///
  /// In Java this is a nested interface inside `Highlighter`.
  /// Swift does not allow nested protocols, so it lives here as a top-level
  /// type in `javax.swing.text` — accessed via
  /// `javax.swing.text.Highlight`.
  @MainActor
  public protocol Highlight: AnyObject {
    /// Start offset (inclusive) of this highlight.
    func getStartOffset() -> Int
    /// End offset (exclusive) of this highlight.
    func getEndOffset() -> Int
    /// The painter used to render this highlight.
    func getPainter() -> any javax.swing.text.HighlightPainter
  }
}
