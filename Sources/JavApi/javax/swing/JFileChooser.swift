/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A file-selection dialog — mirrors `javax.swing.JFileChooser` from Java 1.2.
  ///
  /// `JFileChooser` presents a dialog that lets the user choose a file or
  /// directory.  The three convenience methods are:
  ///
  /// ```swift
  /// let chooser = javax.swing.JFileChooser()
  ///
  /// // Open dialog
  /// let result = chooser.showOpenDialog(parentFrame)
  /// if result == javax.swing.JFileChooser.APPROVE_OPTION {
  ///     let file = chooser.getSelectedFile()
  /// }
  ///
  /// // Save dialog
  /// let result = chooser.showSaveDialog(parentFrame)
  ///
  /// // Custom approve button label
  /// let result = chooser.showDialog(parentFrame, "Select")
  /// ```
  ///
  /// ## Return values
  ///
  /// | Constant | Value |
  /// |---|---|
  /// | `APPROVE_OPTION` | 0 |
  /// | `CANCEL_OPTION`  | 1 |
  /// | `ERROR_OPTION`   | -1 |
  ///
  /// ## Selection modes
  ///
  /// | Constant | Value |
  /// |---|---|
  /// | `FILES_ONLY`             | 0 |
  /// | `DIRECTORIES_ONLY`       | 1 |
  /// | `FILES_AND_DIRECTORIES`  | 2 |
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JFileChooser: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Return value constants
    // -------------------------------------------------------------------------

    public static let APPROVE_OPTION: Int = 0
    public static let CANCEL_OPTION:  Int = 1
    public static let ERROR_OPTION:   Int = -1

    // -------------------------------------------------------------------------
    // MARK: Selection mode constants
    // -------------------------------------------------------------------------

    public static let FILES_ONLY:            Int = 0
    public static let DIRECTORIES_ONLY:      Int = 1
    public static let FILES_AND_DIRECTORIES: Int = 2

    // -------------------------------------------------------------------------
    // MARK: Dialog type constants
    // -------------------------------------------------------------------------

    public static let OPEN_DIALOG:   Int = 0
    public static let SAVE_DIALOG:   Int = 1
    public static let CUSTOM_DIALOG: Int = 2

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var currentDirectory: java.io.File?
    private var selectedFile: java.io.File? = nil
    private var selectedFiles: [java.io.File] = []
    private var fileSelectionMode: Int = FILES_ONLY
    private var multiSelectionEnabled: Bool = false
    private var dialogTitle: String? = nil
    private var approveButtonText: String? = nil
    private var dialogType: Int = OPEN_DIALOG

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public override init() {
      let currentDirectoryPath: String = try! java.lang.System.getProperty("user.home") ?? "."
      self.currentDirectory = java.io.File(currentDirectoryPath)
      super.init()
      updateUI()
    }

    public init(_ currentDirectoryPath: String) {
      self.currentDirectory = java.io.File(currentDirectoryPath)
      super.init()
      updateUI()
    }

    public init(_ currentDirectory: java.io.File) {
      self.currentDirectory = currentDirectory
      super.init()
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "FileChooserUI" }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getCurrentDirectory() -> java.io.File? { currentDirectory }
    public func setCurrentDirectory(_ dir: java.io.File?) { currentDirectory = dir }

    public func getSelectedFile() -> java.io.File? { selectedFile }
    public func setSelectedFile(_ file: java.io.File?) {
      selectedFile = file
      if let f = file { selectedFiles = [f] } else { selectedFiles = [] }
    }

    public func getSelectedFiles() -> [java.io.File] { selectedFiles }
    public func setSelectedFiles(_ files: [java.io.File]) {
      selectedFiles = files
      selectedFile = files.first
    }

    public func getFileSelectionMode() -> Int { fileSelectionMode }
    public func setFileSelectionMode(_ mode: Int) { fileSelectionMode = mode }

    public func isMultiSelectionEnabled() -> Bool { multiSelectionEnabled }
    public func setMultiSelectionEnabled(_ b: Bool) { multiSelectionEnabled = b }

    public func getDialogTitle() -> String? { dialogTitle }
    public func setDialogTitle(_ title: String?) { dialogTitle = title }

    public func getApproveButtonText() -> String? { approveButtonText }
    public func setApproveButtonText(_ text: String?) { approveButtonText = text }

    public func getDialogType() -> Int { dialogType }

    // -------------------------------------------------------------------------
    // MARK: showOpenDialog / showSaveDialog / showDialog
    // -------------------------------------------------------------------------

    /// Shows an "Open" dialog. Returns `APPROVE_OPTION` or `CANCEL_OPTION`.
    @discardableResult
    public func showOpenDialog(_ parent: java.awt.Component?) -> Int {
      dialogType = JFileChooser.OPEN_DIALOG
      return showDialog(parent, approveButtonText ?? "Open")
    }

    /// Shows a "Save" dialog. Returns `APPROVE_OPTION` or `CANCEL_OPTION`.
    @discardableResult
    public func showSaveDialog(_ parent: java.awt.Component?) -> Int {
      dialogType = JFileChooser.SAVE_DIALOG
      return showDialog(parent, approveButtonText ?? "Save")
    }

    /// Shows a dialog with a custom approve-button label.
    /// Returns `APPROVE_OPTION` or `CANCEL_OPTION`.
    @discardableResult
    public func showDialog(_ parent: java.awt.Component?, _ approveButtonText: String) -> Int {
      dialogType = JFileChooser.CUSTOM_DIALOG
      let title = dialogTitle ?? approveButtonText

      let owner = parent?.getParent() as? java.awt.Frame
      let dialog = javax.swing.JDialog(owner, title, true)
      dialog.getContentPane().setLayout(java.awt.BorderLayout())
      dialog.getContentPane().add(self, java.awt.BorderLayout.CENTER)
      dialog.setSize(500, 360)

      // Center on parent
      if let p = parent {
        let pb = p.bounds
        let db = dialog.bounds
        dialog.setLocation(
          pb.x + (pb.width  - db.width)  / 2,
          pb.y + (pb.height - db.height) / 2
        )
      }

      // Store result
      var returnValue = JFileChooser.CANCEL_OPTION
      // The UI delegate's approve/cancel buttons set the return value and
      // hide the dialog; the BasicFileChooserUI installs those handlers.
      // We expose a setter so BasicFileChooserUI can write the result.
      _returnValue = JFileChooser.CANCEL_OPTION
      _dismissDialog = {
        dialog.setVisible(false)
      }

      dialog.setVisible(true)
      returnValue = _returnValue
      _dismissDialog = nil
      return returnValue
    }

    // -------------------------------------------------------------------------
    // MARK: Internal hooks for BasicFileChooserUI
    // -------------------------------------------------------------------------

    /// Set by the UI delegate to record approve/cancel before hiding the dialog.
    var _returnValue: Int = CANCEL_OPTION

    /// Called by the UI delegate to close the enclosing dialog.
    var _dismissDialog: (() -> Void)? = nil

    /// Called by BasicFileChooserUI when the user clicks the approve button.
    public func approveSelection() {
      _returnValue = JFileChooser.APPROVE_OPTION
      _dismissDialog?()
    }

    /// Called by BasicFileChooserUI when the user clicks Cancel.
    public func cancelSelection() {
      _returnValue = JFileChooser.CANCEL_OPTION
      _dismissDialog?()
    }
  }
}
