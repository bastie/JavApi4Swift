/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstrates `java.awt.dnd` drag-and-drop:
/// - A **source list** whose items can be dragged
/// - A **drop target list** that accepts dropped text
/// - A **log area** that records every DnD lifecycle event
@MainActor
class SwingDnDTab {

  static func build() -> javax.swing.JComponent {

    // ── Models ───────────────────────────────────────────────────────────────
    let sourceModel = javax.swing.DefaultListModel<String>()
    sourceModel.addElement("Apple")
    sourceModel.addElement("Banana")
    sourceModel.addElement("Cherry")
    sourceModel.addElement("Date")
    sourceModel.addElement("Elderberry")

    let targetModel = javax.swing.DefaultListModel<String>()
    let logModel    = javax.swing.DefaultListModel<String>()

    // ── Lists ────────────────────────────────────────────────────────────────
    let sourceList = javax.swing.JList<String>(sourceModel)
    sourceList.setSelectionMode(javax.swing.JList<String>.SINGLE_SELECTION)
    sourceList.setBorder(javax.swing.BorderFactory.createTitledBorder("Drag source"))

    let targetList = javax.swing.JList<String>(targetModel)
    targetList.setSelectionMode(javax.swing.JList<String>.SINGLE_SELECTION)
    targetList.setBorder(javax.swing.BorderFactory.createTitledBorder("Drop target"))

    // ── Transferable ─────────────────────────────────────────────────────────
    final class StringTransferable: java.awt.datatransfer.Transferable,
                                    @unchecked Sendable {
      let text: String
      init(_ t: String) { self.text = t }
      func getTransferDataFlavors() -> [java.awt.datatransfer.DataFlavor] {
        [java.awt.datatransfer.DataFlavor.stringFlavor]
      }
      func isDataFlavorSupported(_ f: java.awt.datatransfer.DataFlavor) -> Bool {
        f == java.awt.datatransfer.DataFlavor.stringFlavor
      }
      func getTransferData(_ f: java.awt.datatransfer.DataFlavor) throws -> Any {
        guard f == java.awt.datatransfer.DataFlavor.stringFlavor else {
          throw java.awt.datatransfer.UnsupportedFlavorException(f)
        }
        return text
      }
    }

    // ── DragSourceListener ───────────────────────────────────────────────────
    final class DSL: java.awt.dnd.DragSourceListener, @unchecked Sendable {
      let logModel: javax.swing.DefaultListModel<String>
      init(_ m: javax.swing.DefaultListModel<String>) { self.logModel = m }

      private func log(_ msg: String) {
        MainActor.assumeIsolated { self.logModel.addElement(msg) }
      }
      func dragEnter(_ e: java.awt.dnd.DragSourceDragEvent) {
        log("DragSource: dragEnter")
      }
      func dragOver(_ e: java.awt.dnd.DragSourceDragEvent) {}
      func dropActionChanged(_ e: java.awt.dnd.DragSourceDragEvent) {
        log("DragSource: dropActionChanged → \(e.getDropAction())")
      }
      func dragExit(_ e: java.awt.dnd.DragSourceEvent) {
        log("DragSource: dragExit")
      }
      func dragDropEnd(_ e: java.awt.dnd.DragSourceDropEvent) {
        log("DragSource: dragDropEnd (success=\(e.getDropSuccess()))")
      }
    }
    let dsl = DSL(logModel)

    // ── DragGestureListener ──────────────────────────────────────────────────
    final class DGL: java.awt.dnd.DragGestureListener, @unchecked Sendable {
      let list:     javax.swing.JList<String>
      let model:    javax.swing.DefaultListModel<String>
      let logModel: javax.swing.DefaultListModel<String>
      let dsl:      DSL

      init(_ list: javax.swing.JList<String>,
           _ model: javax.swing.DefaultListModel<String>,
           _ logModel: javax.swing.DefaultListModel<String>,
           _ dsl: DSL) {
        self.list     = list
        self.model    = model
        self.logModel = logModel
        self.dsl      = dsl
      }

      func dragGestureRecognized(_ dge: java.awt.dnd.DragGestureEvent) {
        // Listener wird auf dem MainActor gerufen — nonisolated(unsafe) erlaubt
        // den Zugriff ohne Sendable-Anforderung an dge.
        nonisolated(unsafe) let event = dge
        MainActor.assumeIsolated {
          let idx = list.getSelectedIndex()
          guard idx >= 0, idx < model.getSize() else { return }
          let text = model.getElementAt(idx)
          logModel.addElement("DragGestureRecognized: \"\(text)\"")
          event.startDrag(dragCursor: java.awt.Cursor.getDefaultCursor(),
                          transferable: StringTransferable(text),
                          dsl: dsl)
        }
      }
    }

    let ds  = java.awt.dnd.DragSource.getDefaultDragSource()
    let dgl = DGL(sourceList, sourceModel, logModel, dsl)
    _ = ds.createDefaultDragGestureRecognizer(
      sourceList,
      java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE,
      dgl)

    // ── DropTargetListener ───────────────────────────────────────────────────
    final class DTL: java.awt.dnd.DropTargetListener, @unchecked Sendable {
      let targetModel: javax.swing.DefaultListModel<String>
      let logModel:    javax.swing.DefaultListModel<String>

      init(_ target: javax.swing.DefaultListModel<String>,
           _ log:    javax.swing.DefaultListModel<String>) {
        self.targetModel = target
        self.logModel    = log
      }

      private func log(_ msg: String) {
        MainActor.assumeIsolated { self.logModel.addElement(msg) }
      }

      func dragEnter(_ e: java.awt.dnd.DropTargetDragEvent) {
        e.acceptDrag(java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE)
        log("DropTarget: dragEnter")
      }
      func dragOver(_ e: java.awt.dnd.DropTargetDragEvent) {
        e.acceptDrag(java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE)
      }
      func dropActionChanged(_ e: java.awt.dnd.DropTargetDragEvent) {
        log("DropTarget: dropActionChanged")
      }
      func dragExit(_ e: java.awt.dnd.DropTargetEvent) {
        log("DropTarget: dragExit")
      }
      func drop(_ e: java.awt.dnd.DropTargetDropEvent) {
        e.acceptDrop(java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE)
        let t = e.getTransferable()
        if t.isDataFlavorSupported(java.awt.datatransfer.DataFlavor.stringFlavor),
           let text = try? t.getTransferData(java.awt.datatransfer.DataFlavor.stringFlavor) as? String {
          MainActor.assumeIsolated {
            self.targetModel.addElement(text)
            self.logModel.addElement("DropTarget: drop \"\(text)\" ✓")
          }
          e.dropComplete(true)
        } else {
          e.dropComplete(false)
          log("DropTarget: drop failed (unsupported flavor)")
        }
      }
    }

    let dtl = DTL(targetModel, logModel)
    _ = java.awt.dnd.DropTarget(targetList,
                                java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE,
                                dtl)

    // ── Buttons ──────────────────────────────────────────────────────────────
    let clearTargetBtn = javax.swing.JButton("Clear target")
    clearTargetBtn.addActionListener { _ in
      targetModel.removeAllElements()
      logModel.addElement("Target list cleared")
    }

    let clearLogBtn = javax.swing.JButton("Clear log")
    clearLogBtn.addActionListener { _ in logModel.removeAllElements() }

    // ── Log list ─────────────────────────────────────────────────────────────
    let logList = javax.swing.JList<String>(logModel)
    logList.setEnabled(false)
    logList.setBorder(javax.swing.BorderFactory.createTitledBorder("DnD event log"))
    let logScroll = javax.swing.JScrollPane(logList)
    logScroll.setPreferredSize(java.awt.Dimension(0, 160))

    // ── Layout ───────────────────────────────────────────────────────────────
    let listsPanel = javax.swing.JPanel(java.awt.GridLayout(1, 2, 8, 0))
    listsPanel.add(javax.swing.JScrollPane(sourceList))
    listsPanel.add(javax.swing.JScrollPane(targetList))

    let topBtnPanel = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT))
    topBtnPanel.add(clearTargetBtn)

    let logBtnPanel = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT))
    logBtnPanel.add(clearLogBtn)

    let logPanel = javax.swing.JPanel(java.awt.BorderLayout())
    logPanel.add(logScroll,   java.awt.BorderLayout.CENTER)
    logPanel.add(logBtnPanel, java.awt.BorderLayout.SOUTH)

    let outer = javax.swing.JPanel(java.awt.BorderLayout(8, 8))
    outer.setBorder(javax.swing.BorderFactory.createEmptyBorder(8, 8, 8, 8))
    outer.add(topBtnPanel, java.awt.BorderLayout.NORTH)
    outer.add(listsPanel,  java.awt.BorderLayout.CENTER)
    outer.add(logPanel,    java.awt.BorderLayout.SOUTH)

    return outer
  }
}
