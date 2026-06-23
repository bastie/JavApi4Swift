/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// A color-selection dialog — mirrors `javax.swing.JColorChooser` from Java 1.2.
  ///
  /// `JColorChooser` lets the user pick a color from swatches, HSB sliders, or
  /// RGB sliders.  The most common use is the static convenience method:
  ///
  /// ```swift
  /// if let color = javax.swing.JColorChooser.showDialog(
  ///         frame, "Choose Color", javax.swing.JColorChooser.initialColor) {
  ///     view.setBackground(color)
  /// }
  /// ```
  ///
  /// The component can also be embedded directly:
  ///
  /// ```swift
  /// let chooser = javax.swing.JColorChooser(java.awt.Color.blue)
  /// panel.add(chooser)
  /// // … later …
  /// let picked = chooser.getColor()
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  open class JColorChooser: javax.swing.JComponent {

    // -------------------------------------------------------------------------
    // MARK: State
    // -------------------------------------------------------------------------

    private var color: java.awt.Color

    // -------------------------------------------------------------------------
    // MARK: Init
    // -------------------------------------------------------------------------

    public init(_ initialColor: java.awt.Color = java.awt.Color.white) {
      self.color = initialColor
      super.init()
      updateUI()
    }

    // -------------------------------------------------------------------------
    // MARK: UI delegate
    // -------------------------------------------------------------------------

    override open func getUIClassID() -> String { "ColorChooserUI" }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getColor() -> java.awt.Color { color }
    public func setColor(_ newColor: java.awt.Color) { color = newColor }
    public func setColor(_ r: Int, _ g: Int, _ b: Int) {
      color = java.awt.Color(r, g, b)
    }

    // -------------------------------------------------------------------------
    // MARK: showDialog
    // -------------------------------------------------------------------------

    /// Displays a modal color-chooser dialog.
    ///
    /// - Returns: The selected `Color`, or `nil` if the user cancelled.
    public static func showDialog(
      _ component: java.awt.Component?,
      _ title: String,
      _ initialColor: java.awt.Color?
    ) -> java.awt.Color? {
      let chooser = JColorChooser(initialColor ?? java.awt.Color.white)
      var approved = false

      let owner = component?.getParent() as? java.awt.Frame
      let dialog = javax.swing.JDialog(owner, title, true)
      dialog.getContentPane().setLayout(java.awt.BorderLayout())
      dialog.getContentPane().add(chooser, java.awt.BorderLayout.CENTER)

      // OK / Cancel buttons
      let btnPanel = javax.swing.JPanel(java.awt.FlowLayout())
      let okBtn     = javax.swing.JButton("OK")
      let cancelBtn = javax.swing.JButton("Cancel")

      okBtn.addActionListener(_SwingClosureActionListener { _ in
        approved = true
        dialog.setVisible(false)
      })
      cancelBtn.addActionListener(_SwingClosureActionListener { _ in
        dialog.setVisible(false)
      })

      btnPanel.add(okBtn)
      btnPanel.add(cancelBtn)
      dialog.getContentPane().add(btnPanel, java.awt.BorderLayout.SOUTH)
      dialog.setSize(420, 300)

      // Center on parent
      if let c = component {
        let pb = c.bounds
        let db = dialog.bounds
        dialog.setLocation(
          pb.x + (pb.width  - db.width)  / 2,
          pb.y + (pb.height - db.height) / 2
        )
      }

      dialog.setVisible(true)
      return approved ? chooser.getColor() : nil
    }
  }
}
