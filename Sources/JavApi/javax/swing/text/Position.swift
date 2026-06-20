/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// A sticky reference to a location in a `Document` — mirrors
  /// `javax.swing.text.Position` from Java 1.2 / JFC 1.0.
  ///
  /// Unlike a plain integer offset, a `Position` automatically tracks
  /// insertions and deletions so that it always refers to the same
  /// logical location in the text even as the document changes.
  ///
  /// ## Bias
  ///
  /// When text is inserted exactly at the position's offset, `bias`
  /// determines whether the position moves forward (`FORWARD`) or
  /// stays in place (`BACKWARD`).
  ///
  /// - Since: Java 1.2 / JFC 1.0
  @MainActor
  public protocol Position: AnyObject {

    /// Returns the current character offset of this position in the document.
    func getOffset() -> Int
  }
}

// -----------------------------------------------------------------------------
// MARK: Bias
// -----------------------------------------------------------------------------

extension javax.swing.text {

  /// Describes how a `Position` behaves when text is inserted at its offset.
  ///
  /// - `FORWARD`: the position moves past the inserted text (offset increases).
  /// - `BACKWARD`: the position stays before the inserted text (offset unchanged).
  public enum Bias {
    /// The position moves forward past any text inserted at the same offset.
    case FORWARD
    /// The position stays before any text inserted at the same offset.
    case BACKWARD
  }
}
