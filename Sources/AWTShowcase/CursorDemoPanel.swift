/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstrates java.awt.Cursor — cycles through all predefined cursor types.
@MainActor
final class CursorDemoPanel: java.awt.Panel {
  
  private static let cursors: [(Int, String)] = [
    (java.awt.Cursor.DEFAULT_CURSOR,   "DEFAULT"),
    (java.awt.Cursor.CROSSHAIR_CURSOR, "CROSSHAIR"),
    (java.awt.Cursor.TEXT_CURSOR,      "TEXT"),
    (java.awt.Cursor.WAIT_CURSOR,      "WAIT"),
    (java.awt.Cursor.HAND_CURSOR,      "HAND"),
    (java.awt.Cursor.MOVE_CURSOR,      "MOVE"),
    (java.awt.Cursor.N_RESIZE_CURSOR,  "N_RESIZE"),
    (java.awt.Cursor.S_RESIZE_CURSOR,  "S_RESIZE"),
    (java.awt.Cursor.E_RESIZE_CURSOR,  "E_RESIZE"),
    (java.awt.Cursor.W_RESIZE_CURSOR,  "W_RESIZE"),
    (java.awt.Cursor.NE_RESIZE_CURSOR, "NE_RESIZE"),
    (java.awt.Cursor.NW_RESIZE_CURSOR, "NW_RESIZE"),
    (java.awt.Cursor.SE_RESIZE_CURSOR, "SE_RESIZE"),
    (java.awt.Cursor.SW_RESIZE_CURSOR, "SW_RESIZE"),
  ]
  
  private var currentIndex = 0
  private let nameLabel: java.awt.Label
  
  override init() {
    nameLabel = try! java.awt.Label("Cursor: DEFAULT", java.awt.Label.CENTER)
    super.init()
    setLayout(java.awt.BorderLayout())
    
    nameLabel.setPreferredSize(java.awt.Dimension(160, 24))
    add(nameLabel, java.awt.BorderLayout.CENTER)
    
    let nav = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.CENTER, 4, 2))
    let prevBtn = java.awt.Button("◀")
    prevBtn.setPreferredSize(java.awt.Dimension(32, 22))
    prevBtn.addActionListener(CursorNavListener(panel: self, dir: -1))
    let nextBtn = java.awt.Button("▶")
    nextBtn.setPreferredSize(java.awt.Dimension(32, 22))
    nextBtn.addActionListener(CursorNavListener(panel: self, dir: +1))
    nav.add(prevBtn)
    nav.add(nextBtn)
    nav.setPreferredSize(java.awt.Dimension(80, 28))
    add(nav, java.awt.BorderLayout.SOUTH)
  }
  
  func step(_ dir: Int) {
    currentIndex = (currentIndex + dir + CursorDemoPanel.cursors.count) % CursorDemoPanel.cursors.count
    let (type, name) = CursorDemoPanel.cursors[currentIndex]
    setCursor(java.awt.Cursor.getPredefinedCursor(type))
    nameLabel.setText("Cursor: \(name)")
    System.out.println("Cursor changed to: \(java.awt.Cursor.getPredefinedCursor(type).getName())")
  }
}
