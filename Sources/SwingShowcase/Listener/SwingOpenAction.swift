/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

@MainActor
final class SwingOpenAction: SwingShowcaseAction {
  override init() {
    super.init("Open…")
    if let icon = SwingOpenAction.toolbarIcon(named: "toolbar-open") {
      putValue(SwingOpenAction.SMALL_ICON, icon)
    }
    putValue(SwingOpenAction.SHORT_DESCRIPTION, "Open a file" as AnyObject)
  }
  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let chooser = javax.swing.JFileChooser()
    chooser.setDialogTitle("Open File")
    let result = chooser.showOpenDialog(nil)
    if result == javax.swing.JFileChooser.APPROVE_OPTION,
       let file = chooser.getSelectedFile() {
      print("File > Open: \(file.getAbsolutePath())")
    }
  }
}
