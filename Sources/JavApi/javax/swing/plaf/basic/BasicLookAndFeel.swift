/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// The Basic Look & Feel — the foundation L&F shipped with JavApi⁴Swift.
  ///
  /// `BasicLookAndFeel` registers factory closures for all implemented
  /// component-UI classes in `javax.swing.plaf.basic`.  It serves as the
  /// default L&F installed by `UIManager` at startup.
  ///
  /// ## Registered UIs
  ///
  /// | Key               | UI class               |
  /// |-------------------|------------------------|
  /// | `"ButtonUI"`      | `BasicButtonUI`        |
  /// | `"CheckBoxUI"`    | `BasicCheckBoxUI`      |
  /// | `"LabelUI"`       | `BasicLabelUI`         |
  /// | `"MenuBarUI"`     | `BasicMenuBarUI`       |
  /// | `"PopupMenuUI"`   | `BasicPopupMenuUI`     |
  /// | `"RadioButtonUI"` | `BasicRadioButtonUI`   |
  /// | `"TextAreaUI"`    | `BasicTextAreaUI`      |
  /// | `"TextFieldUI"`   | `BasicTextFieldUI`     |
  /// | `"SplitPaneUI"`   | `BasicSplitPaneUI`     |
  /// | `"ToggleButtonUI"`| `BasicToggleButtonUI`  |
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicLookAndFeel: javax.swing.LookAndFeel {

    public override init() {}

    override open func getName()        -> String { "Basic" }
    override open func getID()          -> String { "Basic" }
    override open func getDescription() -> String { "The Basic Look and Feel" }
    override open func isNativeLookAndFeel()    -> Bool { false }
    override open func isSupportedLookAndFeel() -> Bool { true  }

    override open func getDefaults() -> javax.swing.UIDefaults {
      let d = javax.swing.UIDefaults()
      d["ButtonUI"]       = { javax.swing.plaf.basic.BasicButtonUI()       }
      d["CheckBoxUI"]     = { javax.swing.plaf.basic.BasicCheckBoxUI()     }
      d["ComboBoxUI"]     = { javax.swing.plaf.basic.BasicComboBoxUI()     }
      d["LabelUI"]        = { javax.swing.plaf.basic.BasicLabelUI()        }
      d["ListUI"]         = { javax.swing.plaf.basic.BasicListUI()         }
      d["MenuBarUI"]      = { javax.swing.plaf.basic.BasicMenuBarUI()      }
      d["PopupMenuUI"]    = { javax.swing.plaf.basic.BasicPopupMenuUI()    }
      d["RadioButtonUI"]  = { javax.swing.plaf.basic.BasicRadioButtonUI()  }
      d["ScrollBarUI"]    = { javax.swing.plaf.basic.BasicScrollBarUI()    }
      d["ScrollPaneUI"]   = { javax.swing.plaf.basic.BasicScrollPaneUI()   }
      d["SpinnerUI"]      = { javax.swing.plaf.basic.BasicSpinnerUI()      }
      d["FormattedTextFieldUI"] = { javax.swing.plaf.basic.BasicTextFieldUI()    }
      d["PasswordFieldUI"] = { javax.swing.plaf.basic.BasicPasswordFieldUI() }
      d["TextAreaUI"]     = { javax.swing.plaf.basic.BasicTextAreaUI()     }
      d["TextFieldUI"]    = { javax.swing.plaf.basic.BasicTextFieldUI()    }
      d["SplitPaneUI"]    = { javax.swing.plaf.basic.BasicSplitPaneUI()    }
      d["ToggleButtonUI"] = { javax.swing.plaf.basic.BasicToggleButtonUI() }
      return d
    }
  }
}
