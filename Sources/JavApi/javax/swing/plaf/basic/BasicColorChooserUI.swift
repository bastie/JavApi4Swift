/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// The Basic look-and-feel UI delegate for `JColorChooser`.
  ///
  /// Renders a three-section color picker:
  ///
  /// ```
  /// ┌───────────────────────────────────────────┐
  /// │  Preview: [████████████]  #RRGGBB          │  ← NORTH
  /// ├───────────────────────────────────────────┤
  /// │                                           │
  /// │  Swatch grid  (named web-safe colors)     │  ← CENTER (scrollable)
  /// │                                           │
  /// ├───────────────────────────────────────────┤
  /// │  R: [slider ───────────]  255             │
  /// │  G: [slider ───────────]  128             │  ← SOUTH (RGB sliders)
  /// │  B: [slider ───────────]    0             │
  /// └───────────────────────────────────────────┘
  /// ```
  ///
  /// Clicking a swatch sets the chooser's color immediately and updates
  /// the RGB sliders.  Moving a slider updates the color and the preview.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicColorChooserUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Factory
    // -------------------------------------------------------------------------

    open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      BasicColorChooserUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Install
    // -------------------------------------------------------------------------

    override open func installUI(_ c: javax.swing.JComponent) {
      guard let chooser = c as? javax.swing.JColorChooser else { return }
      chooser.setLayout(java.awt.BorderLayout())
      chooser.setBackground(java.awt.SystemColor.control)
      buildContents(chooser)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ c: javax.swing.JComponent) {
      g.setColor(c.getBackground())
      g.fillRect(0, 0, c.bounds.width, c.bounds.height)
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ c: javax.swing.JComponent) -> java.awt.Dimension? {
      let fm = java.awt.FontMetrics.make(for: c.font)
      let lineH = fm.getHeight()
      return java.awt.Dimension(lineH * 25, lineH * 16)
    }

    // -------------------------------------------------------------------------
    // MARK: Content construction
    // -------------------------------------------------------------------------

    private func buildContents(_ chooser: javax.swing.JColorChooser) {

      // ── Preview strip (NORTH) ───────────────────────────────────────────────
      let previewPanel = javax.swing.JPanel(java.awt.BorderLayout())
      previewPanel.setBackground(java.awt.SystemColor.control)

      let previewSwatch = javax.swing.JPanel()
      previewSwatch.setBackground(chooser.getColor())
      // no setPreferredSize — swatch fills the available WEST slot via BorderLayout
      previewSwatch.setOpaque(true)

      let hexLabel = javax.swing.JLabel("  " + hexString(chooser.getColor()))

      previewPanel.add(javax.swing.JLabel("  Preview: "), java.awt.BorderLayout.WEST)
      previewPanel.add(previewSwatch, java.awt.BorderLayout.CENTER)
      previewPanel.add(hexLabel, java.awt.BorderLayout.EAST)
      chooser.add(previewPanel, java.awt.BorderLayout.NORTH)

      // ── Swatch grid (CENTER) ───────────────────────────────────────────────
      let swatchPanel = javax.swing.JPanel(java.awt.FlowLayout())
      swatchPanel.setBackground(java.awt.SystemColor.control)

      for namedColor in namedColors() {
        let swatch = javax.swing.JPanel()
        swatch.setBackground(namedColor)
        // Swatch size: one line-height square (font-relative, no hardcoded pixels)
        let swatchSize = java.awt.FontMetrics.make(for: swatch.font).getHeight()
        swatch.setPreferredSize(java.awt.Dimension(swatchSize, swatchSize))
        swatch.setOpaque(true)
        swatch.setToolTipText(hexString(namedColor))
        // Click handler via mouse listener (use a thin wrapper)
        swatch.addMouseListener(_SwatchMouseListener { [self] in
          chooser.setColor(namedColor)
          previewSwatch.setBackground(namedColor)
          hexLabel.setText("  " + self.hexString(namedColor))
          // Sync sliders via callback
          onColorChanged?(namedColor)
        })
        swatchPanel.add(swatch)
      }

      let swatchScroll = javax.swing.JScrollPane(swatchPanel)
      swatchScroll.setVerticalScrollBarPolicy(
        javax.swing.JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED)
      chooser.add(swatchScroll, java.awt.BorderLayout.CENTER)

      // ── RGB sliders (SOUTH) ────────────────────────────────────────────────
      let sliderPanel = javax.swing.JPanel(java.awt.GridLayout(3, 3, 4, 2))
      sliderPanel.setBackground(java.awt.SystemColor.control)

      let initial = chooser.getColor()
      let rSlider = javax.swing.JSlider(0, 255,
        Int(initial.getRed()   * 255))
      let gSlider = javax.swing.JSlider(0, 255,
        Int(initial.getGreen() * 255))
      let bSlider = javax.swing.JSlider(0, 255,
        Int(initial.getBlue()  * 255))

      let rLabel = javax.swing.JLabel("R:")
      let gLabel = javax.swing.JLabel("G:")
      let bLabel = javax.swing.JLabel("B:")
      let rValue = javax.swing.JLabel("\(rSlider.getValue())")
      let gValue = javax.swing.JLabel("\(gSlider.getValue())")
      let bValue = javax.swing.JLabel("\(bSlider.getValue())")

      func updateFromSliders() {
        let color = java.awt.Color(
          rSlider.getValue(), gSlider.getValue(), bSlider.getValue())
        chooser.setColor(color)
        previewSwatch.setBackground(color)
        hexLabel.setText("  " + hexString(color))
        rValue.setText("\(rSlider.getValue())")
        gValue.setText("\(gSlider.getValue())")
        bValue.setText("\(bSlider.getValue())")
      }

      let sliderListener = _SwingClosureChangeListener { _ in updateFromSliders() }
      rSlider.addChangeListener(sliderListener)
      gSlider.addChangeListener(sliderListener)
      bSlider.addChangeListener(sliderListener)

      // Sync sliders when a swatch is clicked (callback set before swatch loop)
      onColorChanged = { color in
        rSlider.setValue(Int(color.getRed()   * 255))
        gSlider.setValue(Int(color.getGreen() * 255))
        bSlider.setValue(Int(color.getBlue()  * 255))
        rValue.setText("\(rSlider.getValue())")
        gValue.setText("\(gSlider.getValue())")
        bValue.setText("\(bSlider.getValue())")
      }

      sliderPanel.add(rLabel); sliderPanel.add(rSlider); sliderPanel.add(rValue)
      sliderPanel.add(gLabel); sliderPanel.add(gSlider); sliderPanel.add(gValue)
      sliderPanel.add(bLabel); sliderPanel.add(bSlider); sliderPanel.add(bValue)
      chooser.add(sliderPanel, java.awt.BorderLayout.SOUTH)
    }

    // -------------------------------------------------------------------------
    // MARK: Helpers
    // -------------------------------------------------------------------------

    /// Callback from swatch clicks to sync RGB sliders; set during buildContents.
    private var onColorChanged: ((java.awt.Color) -> Void)? = nil

    private func hexString(_ color: java.awt.Color) -> String {
      let r = Int(color.getRed()   * 255)
      let g = Int(color.getGreen() * 255)
      let b = Int(color.getBlue()  * 255)
      return String(format: "#%02X%02X%02X", r, g, b)
    }

    /// A representative subset of web-safe / CSS named colors.
    private func namedColors() -> [java.awt.Color] {
      [
        // Greys
        java.awt.Color.white,
        java.awt.Color(211, 211, 211),
        java.awt.Color(169, 169, 169),
        java.awt.Color(128, 128, 128),
        java.awt.Color( 64,  64,  64),
        java.awt.Color.black,
        // Reds
        java.awt.Color(255, 200, 200),
        java.awt.Color(255, 128, 128),
        java.awt.Color.red,
        java.awt.Color(180,   0,   0),
        java.awt.Color(128,   0,   0),
        // Oranges / Yellows
        java.awt.Color(255, 165,   0),
        java.awt.Color(255, 200,   0),
        java.awt.Color.yellow,
        java.awt.Color(200, 200,   0),
        // Greens
        java.awt.Color(144, 238, 144),
        java.awt.Color(  0, 200,   0),
        java.awt.Color.green,
        java.awt.Color(  0, 128,   0),
        java.awt.Color(  0,  64,   0),
        // Blues / Cyans
        java.awt.Color(173, 216, 230),
        java.awt.Color(  0, 191, 255),
        java.awt.Color.cyan,
        java.awt.Color.blue,
        java.awt.Color(  0,   0, 128),
        // Purples / Magentas
        java.awt.Color(216, 191, 216),
        java.awt.Color(147, 112, 219),
        java.awt.Color.magenta,
        java.awt.Color(128,   0, 128),
        java.awt.Color( 75,   0, 130),
        // Browns / Skin tones
        java.awt.Color(210, 180, 140),
        java.awt.Color(160,  82,  45),
        java.awt.Color(139,  90,  43),
      ]
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Thin mouse-listener wrapper for swatch clicks
  // ---------------------------------------------------------------------------

  /// Internal helper: calls `action` on mouseClicked.
  @MainActor
  private final class _SwatchMouseListener: java.awt.event.MouseAdapter {
    private let action: () -> Void
    init(_ action: @escaping () -> Void) { self.action = action }
    override func mouseClicked(_ e: java.awt.event.MouseEvent) { action() }
  }
}
