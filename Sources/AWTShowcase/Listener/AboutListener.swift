/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class AboutListener: java.awt.event.ActionListener {
  private weak var owner: java.awt.Frame?
  init(owner: java.awt.Frame) { self.owner = owner }
  
  func actionPerformed (_ e: java.awt.event.ActionEvent) {
    let dialog = java.awt.Dialog (owner, "About JavApi⁴Swift", true)
    dialog.setLayout (java.awt.BorderLayout())
    dialog.setPreferredSize (java.awt.Dimension(320, 260))
    dialog.bounds = java.awt.Rectangle(0, 0, 320, 260)
    
    // Logo oben
    let logo = LogoCanvas()
    logo.setPreferredSize (java.awt.Dimension(320, 140))
    dialog.add(logo, java.awt.BorderLayout.NORTH)
    
    // Text mittig
    let info = java.awt.Label ("JavApi⁴Swift  •  Java AWT 4 Swift", java.awt.Label.CENTER)
    info.setPreferredSize (java.awt.Dimension(320, 40))
    dialog.add (info, java.awt.BorderLayout.CENTER)
    
    // Schließen-Button unten
    let closeBtn = java.awt.Button ("Close")
    closeBtn.setPreferredSize (java.awt.Dimension(100, 30))
    let south = java.awt.Panel (java.awt.FlowLayout(java.awt.FlowLayout.CENTER))
    south.setPreferredSize (java.awt.Dimension(320, 50))
    south.add (closeBtn)
    dialog.add (south, java.awt.BorderLayout.SOUTH)
    
    closeBtn.addActionListener (DialogCloseListener(dialog: dialog))
    
    dialog.validate ()
    dialog.setVisible (true)
  }
}
