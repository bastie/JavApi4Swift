/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// All peer protocols beyond ComponentPeer are defined here.
// Each inherits from ComponentPeer and adds only the component-specific methods.

extension java.awt.peer {

  // ---------------------------------------------------------------------------
  // MARK: Container hierarchy
  // ---------------------------------------------------------------------------

  /// - Since: Java 1.0
  public protocol ContainerPeer: ComponentPeer {
    func insets() -> java.awt.Insets
  }

  /// - Since: Java 1.0
  public protocol PanelPeer: ContainerPeer {}

  /// - Since: Java 1.0
  public protocol CanvasPeer: ComponentPeer {}

  // ---------------------------------------------------------------------------
  // MARK: Window hierarchy
  // ---------------------------------------------------------------------------

  /// - Since: Java 1.0
  public protocol WindowPeer: ContainerPeer {
    func toFront()
    func toBack()
  }

  /// - Since: Java 1.0
  public protocol DialogPeer: WindowPeer {
    func setTitle(_ title: String)
    func setResizable(_ resizable: Bool)
  }

  /// - Since: Java 1.0
  public protocol FileDialogPeer: DialogPeer {
    func setFile(_ file: String)
    func setDirectory(_ dir: String)
    func setFilenameFilter(_ filter: any java.io.FilenameFilter)
  }

  /// - Since: Java 1.0
  public protocol FramePeer: WindowPeer {
    func setTitle(_ title: String)
    func setResizable(_ resizable: Bool)
    func setIconImage(_ image: java.awt.Image)
    func setMenuBar(_ mb: java.awt.MenuBar?)
    func setCursor(_ cursorType: Int)
  }

  // ---------------------------------------------------------------------------
  // MARK: Simple components
  // ---------------------------------------------------------------------------

  /// - Since: Java 1.0
  public protocol ButtonPeer: ComponentPeer {
    func setLabel(_ label: String)
  }

  /// - Since: Java 1.0
  public protocol CheckboxPeer: ComponentPeer {
    func setState(_ state: Bool)
    func setCheckboxGroup(_ g: java.awt.CheckboxGroup?)
    func setLabel(_ label: String)
  }

  /// - Since: Java 1.0
  public protocol CheckboxMenuItemPeer: MenuItemPeer {
    func setState(_ state: Bool)
  }

  /// - Since: Java 1.0
  public protocol ChoicePeer: ComponentPeer {
    func addItem(_ item: String, _ index: Int)
    func select(_ index: Int)
  }

  /// - Since: Java 1.0
  public protocol ListPeer: ComponentPeer {
    func addItem(_ item: String, _ index: Int)
    func delItems(_ start: Int, _ end: Int)
    func clear()
    func select(_ index: Int)
    func deselect(_ index: Int)
    func getSelectedIndexes() -> [Int]
    func setMultipleSelections(_ v: Bool)
    func minimumSize(_ rows: Int) -> java.awt.Dimension
    func preferredSize(_ rows: Int) -> java.awt.Dimension
    func makeVisible(_ index: Int)
  }

  /// - Since: Java 1.0
  public protocol ScrollbarPeer: ComponentPeer {
    func setValue(_ value: Int)
    func setValues(_ value: Int, _ visible: Int, _ minimum: Int, _ maximum: Int)
    func setLineIncrement(_ l: Int)
    func setPageIncrement(_ l: Int)
  }

  // ---------------------------------------------------------------------------
  // MARK: Text components
  // ---------------------------------------------------------------------------

  /// - Since: JJava 1.0
  public protocol TextComponentPeer: ComponentPeer {
    func setEditable(_ editable: Bool)
    func getText() -> String
    func setText(_ text: String)
    func getSelectionStart() -> Int
    func getSelectionEnd() -> Int
    func select(_ selStart: Int, _ selEnd: Int)
  }

  /// - Since: Java 1.0
  public protocol TextFieldPeer: TextComponentPeer {
    func setEchoCharacter(_ c: Character)
    func preferredSize(_ cols: Int) -> java.awt.Dimension
    func minimumSize(_ cols: Int) -> java.awt.Dimension
  }

  /// - Since: Java 1.0
  public protocol TextAreaPeer: TextComponentPeer {
    func insertText(_ text: String, _ pos: Int)
    func replaceText(_ text: String, _ start: Int, _ end: Int)
    func preferredSize(_ rows: Int, _ cols: Int) -> java.awt.Dimension
    func minimumSize(_ rows: Int, _ cols: Int) -> java.awt.Dimension
  }

  // ---------------------------------------------------------------------------
  // MARK: Menu peers
  // ---------------------------------------------------------------------------

  /// - Since: Java 1.0
  @MainActor
  public protocol MenuComponentPeer: AnyObject {
    func dispose()
  }

  /// - Since: Java 1.0
  public protocol MenuItemPeer: MenuComponentPeer {
    func setLabel(_ label: String)
    func enable()
    func disable()
  }

  /// - Since: Java 1.0
  public protocol MenuPeer: MenuItemPeer {
    func addSeparator()
    func addItem(_ item: java.awt.MenuItem)
    func delItem(_ index: Int)
  }

  /// - Since: Java 1.0
  public protocol MenuBarPeer: MenuComponentPeer {
    func addMenu(_ m: java.awt.Menu)
    func delMenu(_ index: Int)
    func addHelpMenu(_ m: java.awt.Menu)
  }
}
