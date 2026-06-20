/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// Paints a single highlighted region — mirrors `Highlighter.HighlightPainter`
  /// from Java 1.2 / JFC 1.0.
  ///
  /// In Java this is a nested interface inside `Highlighter`.
  /// Swift does not allow nested protocols, so it lives here as a top-level
  /// type in `javax.swing.text` — accessed via
  /// `javax.swing.text.HighlightPainter`.
  @MainActor
  public protocol HighlightPainter: AnyObject {
    /// Renders one highlight region on `g`.
    func paint(_ g: java.awt.Graphics,
               _ p0: Int, _ p1: Int,
               _ bounds: java.awt.Shape,
               _ c: javax.swing.text.JTextComponent)
  }
}
