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
      AWTShowcaseApp().buildShowcase(width: 800, height: 500).setVisible(true)
    }
    java.awt.Toolkit.getDefaultToolkit().runEventLoop()
  }
  
  @MainActor
  private func buildShowcase(width: Int, height: Int) -> java.awt.Frame {
    
    let frame = java.awt.Frame("JavApi⁴Swift – AWT Showcase")
    frame.setSize(width, height)
    frame.setMinimumSize(java.awt.Dimension(700, 420))
    frame.setLayout(java.awt.BorderLayout())
    
    // NORTH height for canvas sizing (controls height is determined by LayoutManager)
    let northH    = 40
    // Estimate canvas height: use a reasonable default; the LayoutManager
    // computes the real southPanel height from its children's preferred sizes.
    let centerH   = height - northH - 80  // 80 = rough one-row controls estimate
    
    // ── NORTH: title label ───────────────────────────────────────────────────
    let title = try! java.awt.Label("Panel · Canvas · Button · Checkbox · TextField · Label · TextArea · Scrollbar · ScrollPane · Choice · List", java.awt.Label.CENTER)
    title.setMinimumSize(java.awt.Dimension(200, 30))
    frame.add(title, java.awt.BorderLayout.NORTH)

    // ── CENTER: split view — ScrollPane+Canvas (left) + TextArea (right) ───────
    let centerPanel = java.awt.Panel(java.awt.BorderLayout())

    // ColorGridCanvas (double height) — setBounds sets the virtual content of ScrollPane
    let bigCanvas = ColorGridCanvas()
    bigCanvas.setBounds(0, 0, width / 2, centerH * 2)

    // PopupMenu on Canvas
    let canvasPopup = java.awt.PopupMenu("Canvas")
    let copyItem = java.awt.MenuItem("Copy")
    copyItem.addActionListener(ShowcaseActionListener())
    let pasteItem = java.awt.MenuItem("Paste")
    pasteItem.addActionListener(ShowcaseActionListener())
    canvasPopup.add(copyItem)
    canvasPopup.add(pasteItem)
    canvasPopup.addSeparator()
    let quitFromPopup = java.awt.MenuItem("Quit")
    quitFromPopup.addActionListener(ShowcaseActionListener())
    canvasPopup.add(quitFromPopup)
    bigCanvas.popupMenu = canvasPopup

    // ScrollPane on WEST in centerPanel — preferredSize from child + scrollbars
    let scrollPane = java.awt.ScrollPane()
    scrollPane.setMinimumSize(java.awt.Dimension(80, 60))
    scrollPane.add(bigCanvas)
    centerPanel.add(scrollPane, java.awt.BorderLayout.WEST)

    // TextArea fills CENTER — BorderLayout gives it all remaining space
    let textArea = java.awt.TextArea("Edit me here…\nLine 2\nLine 3", 5, 20)
    centerPanel.add(textArea, java.awt.BorderLayout.CENTER)

    // PolygonCanvas on EAST — preferredSize from PolygonCanvas.getPreferredSize()
    let polyCanvas = PolygonCanvas()
    polyCanvas.setMinimumSize(java.awt.Dimension(60, 60))
    centerPanel.add(polyCanvas, java.awt.BorderLayout.EAST)

    frame.add(centerPanel, java.awt.BorderLayout.CENTER)

    // ── EAST: standalone vertical Scrollbar — preferredSize from Scrollbar
    let scrollbar = java.awt.Scrollbar(java.awt.Scrollbar.VERTICAL, 0, 20, 0, 100)
    scrollbar.setMinimumSize(java.awt.Dimension(12, 40))
    frame.add(scrollbar, java.awt.BorderLayout.EAST)

    // ── SOUTH: controls panel ────────────────────────────────────────────────
    let controls = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 8, 4))
    controls.setMinimumSize(java.awt.Dimension(200, 60))

    // Button — preferredSize from Button.getPreferredSize()
    let btn = java.awt.Button("Click me")
    btn.setMinimumSize(java.awt.Dimension(50, 22))
    btn.addActionListener(ShowcaseActionListener())
    controls.add(btn)

    // TextField — preferredSize from TextField.getPreferredSize()
    let field = java.awt.TextField("Type here…", columns: 12)
    field.setMinimumSize(java.awt.Dimension(60, 22))
    controls.add(field)

    // Checkboxes — preferredSize from Checkbox.getPreferredSize()
    let chkListener = ShowcaseItemListener(label: "Checkbox")

    let chk1 = java.awt.Checkbox("Bold")
    chk1.addItemListener(chkListener)
    controls.add(chk1)

    let chk2 = java.awt.Checkbox("Italic", state: true)
    chk2.addItemListener(chkListener)
    controls.add(chk2)

    // Radio buttons (CheckboxGroup) — preferredSize from Checkbox.getPreferredSize()
    let group = java.awt.CheckboxGroup()
    let rbListener = ShowcaseItemListener(label: "RadioButton")

    let rb1 = java.awt.Checkbox("Small",  state: true,  group: group)
    rb1.addItemListener(rbListener)
    controls.add(rb1)

    let rb2 = java.awt.Checkbox("Medium", state: false, group: group)
    rb2.addItemListener(rbListener)
    controls.add(rb2)

    let rb3 = java.awt.Checkbox("Large",  state: false, group: group)
    rb3.addItemListener(rbListener)
    controls.add(rb3)

    // Choice — preferredSize from Choice.getPreferredSize()
    let choice = java.awt.Choice()
    choice.add("Apple")
    choice.add("Banana")
    choice.add("Cherry")
    choice.add("Durian")
    choice.setMinimumSize(java.awt.Dimension(60, 22))
    choice.addItemListener(ShowcaseItemListener(label: "Choice"))
    controls.add(choice)

    // List — preferredSize from List.getPreferredSize() based on rows=3
    let list = java.awt.List(3, false)
    list.add("Red")
    list.add("Green")
    list.add("Blue")
    list.add("Yellow")
    list.add("Cyan")
    list.add("Magenta")
    list.setMinimumSize(java.awt.Dimension(60, 40))
    list.addItemListener(ShowcaseItemListener(label: "List"))
    list.addActionListener(ShowcaseActionListener())
    controls.add(list)

    // FileDialog buttons — preferredSize from Button.getPreferredSize()
    let openBtn = java.awt.Button("Open…")
    openBtn.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.LOAD))
    controls.add(openBtn)

    let saveBtn = java.awt.Button("Save…")
    saveBtn.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.SAVE))
    controls.add(saveBtn)

    // ── SOUTH: southPanel contains only controls ─────────────────────────────
    // BorderLayout.SOUTH sizes itself to the preferred height of southPanel,
    // which in turn derives its preferred height from the controls FlowLayout.
    // This means no empty space regardless of window width.
    frame.add(controls, java.awt.BorderLayout.SOUTH)
    
    // ── MenuBar ───────────────────────────────────────────────────────────────
    let menuBar = java.awt.MenuBar()
    
    // file menu
    let fileMenu = java.awt.Menu("File")
    let openItem = java.awt.MenuItem("Open…",
                                     java.awt.MenuShortcut(79))   // Cmd+O
    openItem.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.LOAD))
    let saveItem = java.awt.MenuItem("Save…", java.awt.MenuShortcut(83))   // Cmd+S
    saveItem.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.SAVE))
    fileMenu.add(openItem)
    fileMenu.add(saveItem)
    fileMenu.addSeparator()
    let quitItem = java.awt.MenuItem("Quit", java.awt.MenuShortcut(81))   // Cmd+Q
    quitItem.addActionListener(ShowcaseActionListener())
    fileMenu.add(quitItem)
    menuBar.add(fileMenu)
    
    // View menu with CheckboxMenuItem
    let viewMenu = java.awt.Menu("View")
    let toolbarItem = java.awt.CheckboxMenuItem("Toolbar", true)
    toolbarItem.addItemListener(ShowcaseItemListener(label: "CheckboxMenuItem"))
    viewMenu.add(toolbarItem)
    viewMenu.addSeparator()
    
    // submenu
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
    
    
    // LayoutManager-menu
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
    
    // help menu
    let helpMenu = java.awt.Menu("Help")
    let aboutItem = java.awt.MenuItem("About JavApi⁴Swift…")
    aboutItem.addActionListener(AboutListener(owner: frame))
    helpMenu.add(aboutItem)
    helpMenu.addSeparator()
    let sysInfoItem = java.awt.MenuItem("Systeminformations…")
    sysInfoItem.addActionListener(SystemInfoListener(owner: frame))
    helpMenu.add(sysInfoItem)
    menuBar.setHelpMenu(helpMenu)
    
    frame.setMenuBar(menuBar)
    
    frame.addWindowListener(ShowcaseWindowListener())
    
    return frame
  }
}

