/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// A blank rectangular area for custom drawing — mirrors `java.awt.Canvas`.
  ///
  /// Subclass Canvas and override `paint(_ g: Graphics)` to draw.
  /// Canvas is a leaf component: it has no children and no layout manager.
  open class Canvas: Component {

    public override init() {
      super.init()
    }

    /// Override to perform custom drawing.
    override open func paint(_ g: java.awt.Graphics) {
      // default: clear to background color
      g.setColor(background)
      g.fillRect(bounds.x, bounds.y, bounds.width, bounds.height)
    }

    /// Canvas does not support children — override is a no-op safety guard.
    override open func repaint() {
      // platform bridge would trigger paint() here
    }
  }
}
