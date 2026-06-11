/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

// ---------------------------------------------------------------------------
// MARK: - Application entry point — Java 1.1 style
// ---------------------------------------------------------------------------
@main
struct AWTShowcaseApp {
  @MainActor
  static func main() {
    java.awt.EventQueue.invokeLater {
      AWTShowcaseApp().buildShowcase(width: 520, height: 420).setVisible(true)
    }
    java.awt.Toolkit.getDefaultToolkit().runEventLoop()
  }
  
  @MainActor
  private func buildShowcase(width: Int, height: Int) -> java.awt.Frame {
    
    let frame = java.awt.Frame("JavApi⁴Swift – AWT Showcase")
    frame.setSize(width, height)
    frame.setMinimumSize(java.awt.Dimension(380, 280))
    frame.setLayout(java.awt.BorderLayout())
    
    // ── Höhenaufteilung ──────────────────────────────────────────────────────
    // Alle Höhen sind hier zentral definiert; centerH ergibt sich automatisch.
    let northH    = 40
    let controlsH = 90   // oberer SOUTH-Block: FlowLayout mit Widgets
    let demosH    = 60   // unterer SOUTH-Block: GridLayout + CardLayout Demo
    let southH    = controlsH + demosH
    let centerH   = height - northH - southH
    
    // ── NORTH: title label ───────────────────────────────────────────────────
    let title = java.awt.Label(
      "Panel · Canvas · Button · Checkbox · TextField · Label · TextArea · Scrollbar · ScrollPane · Choice · List", java.awt.Label.CENTER)
    title.setPreferredSize(java.awt.Dimension(width, northH))
    title.setMinimumSize(java.awt.Dimension(200, 30))
    frame.add(title, java.awt.BorderLayout.NORTH)
    
    // ── CENTER: split view — ScrollPane+Canvas (left) + TextArea (right) ───────
    let centerPanel = java.awt.Panel(java.awt.BorderLayout())
    // CENTER im äußeren BorderLayout füllt den verbleibenden Platz automatisch
    
    // ColorGridCanvas (doppelte Höhe) — setBounds bestimmt den virtuellen Inhalt der ScrollPane
    let bigCanvas = ColorGridCanvas()
    bigCanvas.setBounds(0, 0, width / 2, centerH * 2)
    
    // PopupMenu auf dem Canvas
    let canvasPopup = java.awt.PopupMenu("Canvas")
    let copyItem = java.awt.MenuItem("Kopieren")
    copyItem.addActionListener(ShowcaseActionListener())
    let pasteItem = java.awt.MenuItem("Einfügen")
    pasteItem.addActionListener(ShowcaseActionListener())
    canvasPopup.add(copyItem)
    canvasPopup.add(pasteItem)
    canvasPopup.addSeparator()
    let quitFromPopup = java.awt.MenuItem("Beenden")
    quitFromPopup.addActionListener(ShowcaseActionListener())
    canvasPopup.add(quitFromPopup)
    bigCanvas.popupMenu = canvasPopup
    
    // ScrollPane als WEST im centerPanel: Breite fix, Höhe vom BorderLayout gesetzt
    let scrollPane = java.awt.ScrollPane()
    scrollPane.setPreferredSize(java.awt.Dimension(width / 2, centerH))
    scrollPane.setMinimumSize(java.awt.Dimension(80, 60))
    scrollPane.add(bigCanvas)
    centerPanel.add(scrollPane, java.awt.BorderLayout.WEST)
    
    // TextArea füllt CENTER — kein explizites preferredSize nötig
    let textArea = java.awt.TextArea("Edit me here…\nLine 2\nLine 3", 5, 20)
    centerPanel.add(textArea, java.awt.BorderLayout.CENTER)
    
    // PolygonCanvas rechts im centerPanel
    let polyCanvas = PolygonCanvas()
    polyCanvas.setPreferredSize(java.awt.Dimension(80, centerH))
    polyCanvas.setMinimumSize(java.awt.Dimension(60, 60))
    centerPanel.add(polyCanvas, java.awt.BorderLayout.EAST)
    
    frame.add(centerPanel, java.awt.BorderLayout.CENTER)
    
    // ── EAST: standalone vertical Scrollbar — Breite fix per preferredSize ───
    let scrollbar = java.awt.Scrollbar(java.awt.Scrollbar.VERTICAL, value: 0, visible: 20, minimum: 0, maximum: 100)
    scrollbar.setPreferredSize(java.awt.Dimension(18, centerH))
    scrollbar.setMinimumSize(java.awt.Dimension(12, 40))
    frame.add(scrollbar, java.awt.BorderLayout.EAST)
    
    // ── SOUTH: controls panel — Höhe fix per preferredSize ───────────────────
    let controls = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 8, 4))
    controls.setPreferredSize(java.awt.Dimension(width, controlsH))
    controls.setMinimumSize(java.awt.Dimension(200, 60))
    
    // Button
    let btn = java.awt.Button("Click me")
    btn.setPreferredSize(java.awt.Dimension(80, 28))
    btn.setMinimumSize(java.awt.Dimension(50, 22))
    btn.addActionListener(ShowcaseActionListener())
    controls.add(btn)
    
    // TextField
    let field = java.awt.TextField("Type here…", columns: 12)
    field.setPreferredSize(java.awt.Dimension(140, 28))
    field.setMinimumSize(java.awt.Dimension(60, 22))
    controls.add(field)
    
    // Checkboxes
    let chkListener = ShowcaseItemListener(label: "Checkbox")
    
    let chk1 = java.awt.Checkbox("Bold")
    chk1.setPreferredSize(java.awt.Dimension(60, 24))
    chk1.addItemListener(chkListener)
    controls.add(chk1)
    
    let chk2 = java.awt.Checkbox("Italic", state: true)
    chk2.setPreferredSize(java.awt.Dimension(60, 24))
    chk2.addItemListener(chkListener)
    controls.add(chk2)
    
    // Radio buttons (CheckboxGroup)
    let group = java.awt.CheckboxGroup()
    let rbListener = ShowcaseItemListener(label: "RadioButton")
    
    let rb1 = java.awt.Checkbox("Small",  state: true,  group: group)
    rb1.setPreferredSize(java.awt.Dimension(65, 24))
    rb1.addItemListener(rbListener)
    controls.add(rb1)
    
    let rb2 = java.awt.Checkbox("Medium", state: false, group: group)
    rb2.setPreferredSize(java.awt.Dimension(75, 24))
    rb2.addItemListener(rbListener)
    controls.add(rb2)
    
    let rb3 = java.awt.Checkbox("Large",  state: false, group: group)
    rb3.setPreferredSize(java.awt.Dimension(65, 24))
    rb3.addItemListener(rbListener)
    controls.add(rb3)
    
    // Choice (drop-down)
    let choice = java.awt.Choice()
    choice.add("Apple")
    choice.add("Banana")
    choice.add("Cherry")
    choice.add("Durian")
    choice.setPreferredSize(java.awt.Dimension(100, 24))
    choice.setMinimumSize(java.awt.Dimension(60, 22))
    choice.addItemListener(ShowcaseItemListener(label: "Choice"))
    controls.add(choice)
    
    // List (scrollable, single-select, 3 sichtbare Zeilen — kompakter für SOUTH)
    let list = java.awt.List(3, false)
    list.add("Red")
    list.add("Green")
    list.add("Blue")
    list.add("Yellow")
    list.add("Cyan")
    list.add("Magenta")
    list.setPreferredSize(java.awt.Dimension(90, 62))
    list.setMinimumSize(java.awt.Dimension(60, 40))
    list.addItemListener(ShowcaseItemListener(label: "List"))
    list.addActionListener(ShowcaseActionListener())
    controls.add(list)
    
    // FileDialog — Öffnen
    let openBtn = java.awt.Button("Open…")
    openBtn.setPreferredSize(java.awt.Dimension(70, 28))
    openBtn.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.LOAD))
    controls.add(openBtn)
    
    // FileDialog — Speichern
    let saveBtn = java.awt.Button("Save…")
    saveBtn.setPreferredSize(java.awt.Dimension(70, 28))
    saveBtn.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.SAVE))
    controls.add(saveBtn)
    
    // ── GridLayout + CardLayout Demo unten ───────────────────────────────────
    let southPanel = java.awt.Panel(java.awt.BorderLayout())
    southPanel.setPreferredSize(java.awt.Dimension(width, southH))
    southPanel.setMinimumSize(java.awt.Dimension(200, 100))
    southPanel.add(controls, java.awt.BorderLayout.NORTH)
    
    let demosPanel = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 6, 4))
    demosPanel.setPreferredSize(java.awt.Dimension(width, demosH))
    
    
    southPanel.add(demosPanel, java.awt.BorderLayout.CENTER)
    
    frame.add(southPanel, java.awt.BorderLayout.SOUTH)
    
    // ── MenuBar ───────────────────────────────────────────────────────────────
    let menuBar = java.awt.MenuBar()
    
    // Datei-Menü
    let fileMenu = java.awt.Menu("Datei")
    let openItem = java.awt.MenuItem("Öffnen…",
                                     java.awt.MenuShortcut(79))   // Cmd+O
    openItem.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.LOAD))
    let saveItem = java.awt.MenuItem("Speichern…", java.awt.MenuShortcut(83))   // Cmd+S
    saveItem.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.SAVE))
    fileMenu.add(openItem)
    fileMenu.add(saveItem)
    fileMenu.addSeparator()
    let quitItem = java.awt.MenuItem("Beenden", java.awt.MenuShortcut(81))   // Cmd+Q
    quitItem.addActionListener(ShowcaseActionListener())
    fileMenu.add(quitItem)
    menuBar.add(fileMenu)
    
    // Ansicht-Menü mit CheckboxMenuItem
    let viewMenu = java.awt.Menu("Ansicht")
    let toolbarItem = java.awt.CheckboxMenuItem("Werkzeugleiste", true)
    toolbarItem.addItemListener(ShowcaseItemListener(label: "CheckboxMenuItem"))
    viewMenu.add(toolbarItem)
    viewMenu.addSeparator()
    
    // Untermenü
    let zoomMenu = java.awt.Menu("Zoom")
    for label in ["25 %", "50 %", "100 %", "200 %"] {
      let zi = java.awt.MenuItem(label)
      zi.addActionListener(ShowcaseActionListener())
      zoomMenu.add(zi)
    }
    viewMenu.add(zoomMenu)
    viewMenu.addSeparator()
    let cursorDemoItem = java.awt.MenuItem("Cursor-Demo…")
    cursorDemoItem.addActionListener(OpenCursorDemoListener(owner: frame))
    viewMenu.add(cursorDemoItem)
    menuBar.add(viewMenu)
    
    
    // LayoutManager-Menü
    let layoutMenu = java.awt.Menu("LayoutManager")
    let blItem = java.awt.MenuItem("BorderLayout")
    blItem.addActionListener(BorderLayoutDemoListener(owner: frame))
    layoutMenu.add(blItem)
    let flItem = java.awt.MenuItem("FlowLayout")
    flItem.addActionListener(FlowLayoutDemoListener(owner: frame))
    layoutMenu.add(flItem)
    let glItem = java.awt.MenuItem("GridLayout")
    glItem.addActionListener(GridLayoutDemoListener(owner: frame))
    layoutMenu.add(glItem)
    let clItem = java.awt.MenuItem("CardLayout")
    clItem.addActionListener(CardLayoutDemoListener(owner: frame))
    layoutMenu.add(clItem)
    layoutMenu.addSeparator()
    let gbItem = java.awt.MenuItem("GridBagLayout")
    gbItem.addActionListener(OpenGridBagDemoActionListener(owner: frame))
    layoutMenu.add(gbItem)
    menuBar.add(layoutMenu)
    
    // Hilfe-Menü
    let helpMenu = java.awt.Menu("Hilfe")
    let aboutItem = java.awt.MenuItem("Über JavApi⁴Swift…")
    aboutItem.addActionListener(AboutListener(owner: frame))
    helpMenu.add(aboutItem)
    helpMenu.addSeparator()
    let sysInfoItem = java.awt.MenuItem("Systeminformationen…")
    sysInfoItem.addActionListener(SystemInfoListener(owner: frame))
    helpMenu.add(sysInfoItem)
    menuBar.setHelpMenu(helpMenu)
    
    frame.setMenuBar(menuBar)
    
    // WindowListener — gibt Lebenszyklusereignisse auf der Konsole aus
    frame.addWindowListener(ShowcaseWindowListener())
    
    return frame
  }
}

