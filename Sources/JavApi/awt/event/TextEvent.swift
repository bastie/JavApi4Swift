/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Fired when the text of a TextComponent changes — mirrors `java.awt.event.TextEvent`.
  public final class TextEvent: java.awt.AWTEvent, @unchecked Sendable {

    public static let TEXT_VALUE_CHANGED = 900

    public override init(_ source: AnyObject, _ id: Int) {
      super.init(source, id)
    }
  }
}
