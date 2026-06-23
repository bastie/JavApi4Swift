/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Builds the "Format" tab panel for the SwingShowcase.
///
/// Demonstrates `JFormattedTextField` with all built-in formatter types,
/// arranged in a two-column `GridLayout` (label | field).
@MainActor
class SwingFormatTab {

  static func build() -> javax.swing.JPanel {

    // Outer panel: BorderLayout so the grid sits at the top and a
    // "Commit all" button lives at the bottom.
    let outer = javax.swing.JPanel(java.awt.BorderLayout())

    // ── Grid: label column + field column ────────────────────────────────────
    // rows=0 means "as many as needed"; cols=2; 8px h-gap, 6px v-gap
    let grid = javax.swing.JPanel(java.awt.GridLayout(0, 2, 8, 6))
    // Note: BorderFactory not yet available — padding via GridBagConstraints insets instead

    // Convenience helpers
    func addRow(_ label: String, _ field: javax.swing.JFormattedTextField) {
      grid.add(javax.swing.JLabel(label))
      grid.add(field)
    }

    // ── 1. NumberFormat — integer ─────────────────────────────────────────────
    let intFmt = java.text.NumberFormat.getIntegerInstance()
    let intField = javax.swing.JFormattedTextField(intFmt, 42)
    addRow("Integer (NumberFormat):", intField)

    // ── 2. NumberFormat — currency ────────────────────────────────────────────
    let currFmt = java.text.NumberFormat.getCurrencyInstance()
    let currField = javax.swing.JFormattedTextField(currFmt, 1234.56)
    addRow("Currency (NumberFormat):", currField)

    // ── 3. NumberFormat — percent ─────────────────────────────────────────────
    let pctFmt = java.text.NumberFormat.getPercentInstance()
    let pctField = javax.swing.JFormattedTextField(pctFmt, 0.75)
    addRow("Percent (NumberFormat):", pctField)

    // ── 4. DateFormat — date ──────────────────────────────────────────────────
    let dateFmt = java.text.DateFormat.getDateInstance(java.text.DateFormat.MEDIUM)
    let dateField = javax.swing.JFormattedTextField(dateFmt, java.util.Date())
    addRow("Date (DateFormat MEDIUM):", dateField)

    // ── 5. DateFormat — date+time ─────────────────────────────────────────────
    let dtFmt = java.text.DateFormat.getDateTimeInstance(
      java.text.DateFormat.SHORT, timeStyle: java.text.DateFormat.SHORT)
    let dtField = javax.swing.JFormattedTextField(dtFmt, java.util.Date())
    addRow("Date+Time (DateFormat SHORT):", dtField)

    // ── 6. InternationalFormatter (explicit) ──────────────────────────────────
    let intlFormatter = javax.swing.text.InternationalFormatter(
      java.text.NumberFormat.getInstance())
    let intlField = javax.swing.JFormattedTextField(9999)
    intlField.setValue(9999)
    // Install via factory
    let intlFactory = javax.swing.text.DefaultFormatterFactory(intlFormatter)
    intlField.setFormatterFactory(intlFactory)
    addRow("InternationalFormatter:", intlField)

    // ── 7. NumberFormatter ────────────────────────────────────────────────────
    let numFormatter = javax.swing.text.NumberFormatter(
      java.text.NumberFormat.getIntegerInstance())
    numFormatter.setMinimum(0)
    numFormatter.setMaximum(999)
    let numFactory = javax.swing.text.DefaultFormatterFactory(numFormatter)
    let numField = javax.swing.JFormattedTextField(42)
    numField.setFormatterFactory(numFactory)
    addRow("NumberFormatter (0–999):", numField)

    // ── 8. DateFormatter ──────────────────────────────────────────────────────
    let dateFormatter = javax.swing.text.DateFormatter(
      java.text.DateFormat.getDateInstance(java.text.DateFormat.LONG))
    let dateFormFactory = javax.swing.text.DefaultFormatterFactory(dateFormatter)
    let dateFormField = javax.swing.JFormattedTextField(java.util.Date())
    dateFormField.setFormatterFactory(dateFormFactory)
    addRow("DateFormatter (LONG):", dateFormField)

    // ── 9. MaskFormatter — phone number ──────────────────────────────────────
    let phoneFmt = (try? javax.swing.text.MaskFormatter("(###) ###-####"))
    let phoneField: javax.swing.JFormattedTextField
    if let fmt = phoneFmt {
      phoneField = javax.swing.JFormattedTextField(fmt)
      phoneField.setValue("(089) 123-4567")
    } else {
      phoneField = javax.swing.JFormattedTextField()
      phoneField.setText("(mask init failed)")
    }
    addRow("MaskFormatter (phone):", phoneField)

    // ── 10. MaskFormatter — date dd/MM/yyyy ──────────────────────────────────
    let dateMaskFmt = (try? javax.swing.text.MaskFormatter("##/##/####"))
    let dateMaskField: javax.swing.JFormattedTextField
    if let fmt = dateMaskFmt {
      dateMaskField = javax.swing.JFormattedTextField(fmt)
      dateMaskField.setValue("01/01/2026")
    } else {
      dateMaskField = javax.swing.JFormattedTextField()
      dateMaskField.setText("(mask init failed)")
    }
    addRow("MaskFormatter (dd/MM/yyyy):", dateMaskField)

    // ── 11. MaskFormatter — hex colour #RRGGBB ────────────────────────────────
    let hexFmt = (try? javax.swing.text.MaskFormatter("#HHHHHH"))
    let hexField: javax.swing.JFormattedTextField
    if let fmt = hexFmt {
      hexField = javax.swing.JFormattedTextField(fmt)
      hexField.setValue("#FF8C00")
    } else {
      hexField = javax.swing.JFormattedTextField()
      hexField.setText("(mask init failed)")
    }
    addRow("MaskFormatter (#RRGGBB hex):", hexField)

    // ── 12. MaskFormatter — IBAN (DE, 22 chars) ───────────────────────────────
    let ibanFmt = (try? javax.swing.text.MaskFormatter("UU## #### #### #### #### ##"))
    let ibanField: javax.swing.JFormattedTextField
    if let fmt = ibanFmt {
      ibanField = javax.swing.JFormattedTextField(fmt)
      ibanField.setValue("DE89 3704 0044 0532 0130 00")
    } else {
      ibanField = javax.swing.JFormattedTextField()
      ibanField.setText("(mask init failed)")
    }
    addRow("MaskFormatter (IBAN DE):", ibanField)

    // ── 13. DefaultFormatter ──────────────────────────────────────────────────
    let defaultFmt = javax.swing.text.DefaultFormatter()
    defaultFmt.setAllowsInvalid(true)
    let defaultFactory = javax.swing.text.DefaultFormatterFactory(defaultFmt)
    let defaultField = javax.swing.JFormattedTextField("free text")
    defaultField.setFormatterFactory(defaultFactory)
    addRow("DefaultFormatter (free):", defaultField)

    outer.add(grid, java.awt.BorderLayout.CENTER)

    // ── Info label at bottom ──────────────────────────────────────────────────
    let info = javax.swing.JLabel("Tab or click away to commit a field's value.")
    outer.add(info, java.awt.BorderLayout.SOUTH)

    return outer
  }
}

