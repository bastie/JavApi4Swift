/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class CursorNavListener: java.awt.event.ActionListener {
  
  private weak var panel: CursorDemoPanel?
  private let dir: Int
  
  init(panel: CursorDemoPanel, dir: Int) {
    self.panel = panel
    self.dir = dir
  }
  
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    panel?.step(dir)
  }
}
