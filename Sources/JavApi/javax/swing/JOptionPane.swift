/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Standard dialog factory — mirrors `javax.swing.JOptionPane` from Java 1.2.
  ///
  /// `JOptionPane` provides static convenience methods for the four most common
  /// dialog types: message, confirm, input, and option dialogs.
  ///
  /// ## Message types
  ///
  /// | Constant | Value | Icon |
  /// |---|---|---|
  /// | `ERROR_MESSAGE`       | 0 | ✖ |
  /// | `INFORMATION_MESSAGE` | 1 | ℹ |
  /// | `WARNING_MESSAGE`     | 2 | ⚠ |
  /// | `QUESTION_MESSAGE`    | 3 | ? |
  /// | `PLAIN_MESSAGE`       | -1 | (none) |
  ///
  /// ## Option types
  ///
  /// | Constant | Value | Buttons |
  /// |---|---|---|
  /// | `DEFAULT_OPTION`      | -1 | OK |
  /// | `YES_NO_OPTION`       | 0  | Yes / No |
  /// | `YES_NO_CANCEL_OPTION`| 1  | Yes / No / Cancel |
  /// | `OK_CANCEL_OPTION`    | 2  | OK / Cancel |
  ///
  /// ## Return values (showConfirmDialog)
  ///
  /// | Constant | Value |
  /// |---|---|
  /// | `YES_OPTION`    | 0 |
  /// | `NO_OPTION`     | 1 |
  /// | `CANCEL_OPTION` | 2 |
  /// | `OK_OPTION`     | 0 |
  /// | `CLOSED_OPTION` | -1 |
  ///
  /// ## Usage
  ///
  /// ```swift
  /// // Message dialog
  /// javax.swing.JOptionPane.showMessageDialog(frame, "Hello!")
  ///
  /// // Confirm dialog
  /// let result = javax.swing.JOptionPane.showConfirmDialog(
  ///     frame, "Are you sure?", "Confirm", javax.swing.JOptionPane.YES_NO_OPTION)
  /// if result == javax.swing.JOptionPane.YES_OPTION { ... }
  ///
  /// // Input dialog
  /// if let name = javax.swing.JOptionPane.showInputDialog(frame, "Enter name:") { ... }
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JOptionPane: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: Message type constants
    // -------------------------------------------------------------------------

    public static let ERROR_MESSAGE:       Int = 0
    public static let INFORMATION_MESSAGE: Int = 1
    public static let WARNING_MESSAGE:     Int = 2
    public static let QUESTION_MESSAGE:    Int = 3
    public static let PLAIN_MESSAGE:       Int = -1

    // -------------------------------------------------------------------------
    // MARK: Option type constants
    // -------------------------------------------------------------------------

    public static let DEFAULT_OPTION:       Int = -1
    public static let YES_NO_OPTION:        Int = 0
    public static let YES_NO_CANCEL_OPTION: Int = 1
    public static let OK_CANCEL_OPTION:     Int = 2

    // -------------------------------------------------------------------------
    // MARK: Return value constants
    // -------------------------------------------------------------------------

    public static let YES_OPTION:    Int = 0
    public static let NO_OPTION:     Int = 1
    public static let CANCEL_OPTION: Int = 2
    public static let OK_OPTION:     Int = 0
    public static let CLOSED_OPTION: Int = -1

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var message: Any?
    private var messageType: Int
    private var optionType: Int
    private var options: [Any]?
    private var initialValue: Any?
    private var value: Any? = nil

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(
      message: Any? = nil,
      messageType: Int = INFORMATION_MESSAGE,
      optionType: Int = DEFAULT_OPTION,
      options: [Any]? = nil,
      initialValue: Any? = nil
    ) {
      self.message = message
      self.messageType = messageType
      self.optionType = optionType
      self.options = options
      self.initialValue = initialValue
      super.init()
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "OptionPaneUI" }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getMessage() -> Any? { message }
    public func setMessage(_ msg: Any?) { message = msg }

    public func getMessageType() -> Int { messageType }
    public func setMessageType(_ type: Int) { messageType = type }

    public func getOptionType() -> Int { optionType }
    public func setOptionType(_ type: Int) { optionType = type }

    public func getOptions() -> [Any]? { options }
    public func setOptions(_ opts: [Any]?) { options = opts }

    public func getInitialValue() -> Any? { initialValue }
    public func setInitialValue(_ val: Any?) {
      initialValue = val
      // Rebuild the UI so the input text field appears/disappears according to
      // the new value. buildContents() inspects getInitialValue(); calling
      // updateUI() re-runs installUI() which rebuilds the content hierarchy.
      updateUI()
    }

    public func getValue() -> Any? { value }
    public func setValue(_ val: Any?) { value = val }

    // -------------------------------------------------------------------------
    // MARK: showMessageDialog
    // -------------------------------------------------------------------------

    /// Displays a modal information dialog.
    public static func showMessageDialog(
      _ parentComponent: java.awt.Component?,
      _ message: Any?,
      _ title: String = "Message",
      _ messageType: Int = INFORMATION_MESSAGE
    ) {
      let pane = JOptionPane(message: message, messageType: messageType,
                             optionType: DEFAULT_OPTION)
      let dialog = pane.createDialog(parentComponent, title)
      dialog.setVisible(true)
    }

    // -------------------------------------------------------------------------
    // MARK: showConfirmDialog
    // -------------------------------------------------------------------------

    /// Displays a modal confirm dialog. Returns `YES_OPTION`, `NO_OPTION`,
    /// `CANCEL_OPTION`, or `CLOSED_OPTION`.
    public static func showConfirmDialog(
      _ parentComponent: java.awt.Component?,
      _ message: Any?,
      _ title: String = "Select an Option",
      _ optionType: Int = YES_NO_CANCEL_OPTION,
      _ messageType: Int = QUESTION_MESSAGE
    ) -> Int {
      let pane = JOptionPane(message: message, messageType: messageType,
                             optionType: optionType)
      let dialog = pane.createDialog(parentComponent, title)
      dialog.setVisible(true)
      guard let v = pane.getValue() as? Int else { return CLOSED_OPTION }
      return v
    }

    // -------------------------------------------------------------------------
    // MARK: showInputDialog
    // -------------------------------------------------------------------------

    /// Displays a modal input dialog. Returns the entered string, or `nil`
    /// if the user cancelled.
    public static func showInputDialog(
      _ parentComponent: java.awt.Component?,
      _ message: Any?,
      _ title: String = "Input",
      _ messageType: Int = QUESTION_MESSAGE
    ) -> String? {
      // initialValue must be set in the constructor — buildContents() runs
      // during updateUI() inside init() and checks getInitialValue() to decide
      // whether to add the input text field. Setting it afterwards is too late.
      let pane = JOptionPane(message: message, messageType: messageType,
                             optionType: OK_CANCEL_OPTION,
                             initialValue: "")
      let dialog = pane.createDialog(parentComponent, title)
      dialog.setVisible(true)
      if let v = pane.getValue() as? String { return v }
      return nil
    }

    /// Simple single-argument variant.
    public static func showInputDialog(_ message: Any?) -> String? {
      return showInputDialog(nil, message)
    }

    // -------------------------------------------------------------------------
    // MARK: showOptionDialog
    // -------------------------------------------------------------------------

    /// Displays a modal dialog with a custom set of option buttons.
    /// Returns the index of the selected option, or `CLOSED_OPTION`.
    public static func showOptionDialog(
      _ parentComponent: java.awt.Component?,
      _ message: Any?,
      _ title: String,
      _ optionType: Int,
      _ messageType: Int,
      _ icon: javax.swing.Icon?,
      _ options: [Any]?,
      _ initialValue: Any?
    ) -> Int {
      let pane = JOptionPane(message: message, messageType: messageType,
                             optionType: optionType, options: options,
                             initialValue: initialValue)
      let dialog = pane.createDialog(parentComponent, title)
      dialog.setVisible(true)
      guard let v = pane.getValue() as? Int else { return CLOSED_OPTION }
      return v
    }

    // -------------------------------------------------------------------------
    // MARK: createDialog
    // -------------------------------------------------------------------------

    /// Wraps this pane in a modal `JDialog`.
    public func createDialog(_ parent: java.awt.Component?, _ title: String) -> JDialog {
      let owner = parent?.getParent() as? java.awt.Frame
      let dialog = JDialog(owner, title, true)
      dialog.getContentPane().setLayout(java.awt.BorderLayout())
      dialog.getContentPane().add(self, java.awt.BorderLayout.CENTER)
      dialog.pack()
      // Center on parent or screen
      if let p = parent {
        let pb = p.bounds
        let db = dialog.bounds
        dialog.setLocation(
          pb.x + (pb.width  - db.width)  / 2,
          pb.y + (pb.height - db.height) / 2
        )
      }
      return dialog
    }
  }
}
