/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Builds the "Range / Progress" tab panel for the SwingShowcase.
///
/// Demonstrates `JSlider` and `JProgressBar` — both backed by a
/// `BoundedRangeModel`.  The slider drives the progress bar live so the
/// coupling between model and view is immediately visible.
@MainActor
class SwingRangeComponentsTab {

  // Keep listeners alive beyond the scope of build().
  private static var _sliderListener: _SliderToProgressBridge?

  static func build() -> javax.swing.JPanel {
    let panel = javax.swing.JPanel(java.awt.GridBagLayout())
    let gbc   = java.awt.GridBagConstraints()

    func addLabel(_ text: String, row: Int) {
      gbc.gridx = 0; gbc.gridy = row
      gbc.gridwidth = 1; gbc.gridheight = 1
      gbc.anchor = java.awt.GridBagConstraints.NORTHWEST
      gbc.insets = java.awt.Insets(4, 8, 4, 8)
      gbc.weightx = 0.0; gbc.weighty = 0.0
      gbc.fill = java.awt.GridBagConstraints.NONE
      panel.add(javax.swing.JLabel(text), gbc)
    }

    func addComp(_ comp: java.awt.Component, row: Int,
                 fill: Int = java.awt.GridBagConstraints.HORIZONTAL) {
      gbc.gridx = 1; gbc.gridy = row
      gbc.gridwidth = 1; gbc.gridheight = 1
      gbc.anchor = java.awt.GridBagConstraints.NORTHWEST
      gbc.insets = java.awt.Insets(4, 4, 4, 8)
      gbc.weightx = 1.0; gbc.weighty = 0.0
      gbc.fill = fill
      panel.add(comp, gbc)
    }

    // ── JSlider (horizontal) ─────────────────────────────────────────────────
    addLabel("JSlider (H):", row: 0)
    let slider = javax.swing.JSlider(0, 100, 50)
    slider.setMajorTickSpacing(25)
    slider.setMinorTickSpacing(5)
    slider.setPaintTicks(true)
    slider.setPaintLabels(true)
    addComp(slider, row: 0)

    // ── JProgressBar (determinate, driven by slider) ─────────────────────────
    addLabel("JProgressBar:", row: 1)
    let progress = javax.swing.JProgressBar(0, 100)
    progress.setValue(50)
    progress.setStringPainted(true)
    addComp(progress, row: 1)

    // Wire slider → progress bar
    let bridge = _SliderToProgressBridge(slider: slider, bar: progress)
    slider.addChangeListener(bridge)
    _sliderListener = bridge

    // ── JSlider (vertical) ───────────────────────────────────────────────────
    addLabel("JSlider (V):", row: 2)
    let vSlider = javax.swing.JSlider(javax.swing.JSlider.VERTICAL, 0, 100, 30)
    vSlider.setMajorTickSpacing(25)
    vSlider.setPaintTicks(true)
    // Fix preferred height so the vertical slider is visible
    gbc.gridx = 1; gbc.gridy = 2
    gbc.fill = java.awt.GridBagConstraints.NONE
    gbc.insets = java.awt.Insets(4, 4, 4, 8)
    gbc.weightx = 1.0; gbc.weighty = 0.0
    panel.add(vSlider, gbc)

    // ── JProgressBar (indeterminate) ─────────────────────────────────────────
    addLabel("Indeterminate:", row: 3)
    let indBar = javax.swing.JProgressBar()
    indBar.setIndeterminate(true)
    indBar.setStringPainted(true)
    indBar.setString("Loading…")
    addComp(indBar, row: 3)

    // ── JProgressBar (vertical) ──────────────────────────────────────────────
    addLabel("JProgressBar (V):", row: 4)
    let vBar = javax.swing.JProgressBar(javax.swing.JProgressBar.VERTICAL, 0, 100)
    vBar.setValue(65)
    vBar.setStringPainted(true)
    gbc.gridx = 1; gbc.gridy = 4
    gbc.fill = java.awt.GridBagConstraints.NONE
    gbc.insets = java.awt.Insets(4, 4, 4, 8)
    gbc.weightx = 1.0; gbc.weighty = 0.0
    panel.add(vBar, gbc)

    // ── Spacer ───────────────────────────────────────────────────────────────
    gbc.gridx = 0; gbc.gridy = 99
    gbc.gridwidth = 2; gbc.weighty = 1.0
    gbc.fill = java.awt.GridBagConstraints.VERTICAL
    panel.add(javax.swing.JPanel(), gbc)

    return panel
  }
}

// =============================================================================
// MARK: - Slider → ProgressBar bridge listener
// =============================================================================

@MainActor
private class _SliderToProgressBridge: javax.swing.event.ChangeListener {
  weak var slider: javax.swing.JSlider?
  weak var bar:    javax.swing.JProgressBar?

  init(slider: javax.swing.JSlider, bar: javax.swing.JProgressBar) {
    self.slider = slider
    self.bar    = bar
  }

  func stateChanged(_ e: javax.swing.event.ChangeEvent) {
    guard let slider, let bar else { return }
    bar.setValue(slider.getValue())
  }
}
