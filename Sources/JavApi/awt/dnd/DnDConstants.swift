/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Constants for Drag-and-Drop actions — mirrors `java.awt.dnd.DnDConstants`.
  ///
  /// - Since: Java 1.2
  public enum DnDConstants {

    /// No action.
    public static let ACTION_NONE: Int = 0x0

    /// Copy action.
    public static let ACTION_COPY: Int = 0x1

    /// Move action.
    public static let ACTION_MOVE: Int = 0x2

    /// Copy-or-move action (bitwise OR of copy and move).
    public static let ACTION_COPY_OR_MOVE: Int = ACTION_COPY | ACTION_MOVE

    /// Link action.
    public static let ACTION_LINK: Int = 0x40000000

    /// Reference action (alias for link).
    public static let ACTION_REFERENCE: Int = ACTION_LINK
  }
}
