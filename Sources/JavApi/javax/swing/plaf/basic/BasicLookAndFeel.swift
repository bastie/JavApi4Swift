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
  /// | Key                    | UI class                    |
  /// |------------------------|-----------------------------|
  /// | `"ButtonUI"`                | `BasicButtonUI`                  |
  /// | `"CheckBoxMenuItemUI"`      | `BasicCheckBoxMenuItemUI`        |
  /// | `"CheckBoxUI"`              | `BasicCheckBoxUI`                |
  /// | `"ColorChooserUI"`          | `BasicColorChooserUI`            |
  /// | `"ComboBoxUI"`              | `BasicComboBoxUI`                |
  /// | `"DesktopPaneUI"`           | `BasicDesktopPaneUI`             |
  /// | `"EditorPaneUI"`            | `BasicTextPaneUI`                |
  /// | `"FileChooserUI"`           | `BasicFileChooserUI`             |
  /// | `"FormattedTextFieldUI"`    | `BasicTextFieldUI`               |
  /// | `"InternalFrameUI"`         | `BasicInternalFrameUI`           |
  /// | `"LabelUI"`                 | `BasicLabelUI`                   |
  /// | `"ListUI"`                  | `BasicListUI`                    |
  /// | `"MenuBarUI"`               | `BasicMenuBarUI`                 |
  /// | `"MenuItemUI"`              | `BasicMenuItemUI`                |
  /// | `"OptionPaneUI"`            | `BasicOptionPaneUI`              |
  /// | `"PasswordFieldUI"`         | `BasicPasswordFieldUI`           |
  /// | `"PopupMenuUI"`             | `BasicPopupMenuUI`               |
  /// | `"ProgressBarUI"`           | `BasicProgressBarUI`             |
  /// | `"RadioButtonMenuItemUI"`   | `BasicRadioButtonMenuItemUI`     |
  /// | `"RadioButtonUI"`           | `BasicRadioButtonUI`             |
  /// | `"ScrollBarUI"`             | `BasicScrollBarUI`               |
  /// | `"ScrollPaneUI"`            | `BasicScrollPaneUI`              |
  /// | `"SeparatorUI"`             | `BasicSeparatorUI`               |
  /// | `"SliderUI"`                | `BasicSliderUI`                  |
  /// | `"SpinnerUI"`               | `BasicSpinnerUI`                 |
  /// | `"SplitPaneUI"`             | `BasicSplitPaneUI`               |
  /// | `"TabbedPaneUI"`            | `BasicTabbedPaneUI`              |
  /// | `"TableHeaderUI"`           | `BasicTableHeaderUI`             |
  /// | `"TableUI"`                 | `BasicTableUI`                   |
  /// | `"TextAreaUI"`              | `BasicTextAreaUI`                |
  /// | `"TextFieldUI"`             | `BasicTextFieldUI`               |
  /// | `"TextPaneUI"`              | `BasicTextPaneUI`                |
  /// | `"ToggleButtonUI"`          | `BasicToggleButtonUI`            |
  /// | `"ToolBarUI"`               | `BasicToolBarUI`                 |
  /// | `"ToolTipUI"`               | `BasicToolTipUI`                 |
  /// | `"TreeUI"`                  | `BasicTreeUI`                    |
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
      d["ButtonUI"]                = { javax.swing.plaf.basic.BasicButtonUI()                }
      d["CheckBoxMenuItemUI"]      = { javax.swing.plaf.basic.BasicCheckBoxMenuItemUI()      }
      d["CheckBoxUI"]              = { javax.swing.plaf.basic.BasicCheckBoxUI()              }
      d["ColorChooserUI"]          = { javax.swing.plaf.basic.BasicColorChooserUI()          }
      d["ComboBoxUI"]              = { javax.swing.plaf.basic.BasicComboBoxUI()              }
      d["DesktopPaneUI"]           = { javax.swing.plaf.basic.BasicDesktopPaneUI()           }
      d["EditorPaneUI"]            = { javax.swing.plaf.basic.BasicTextPaneUI()              }
      d["FileChooserUI"]           = { javax.swing.plaf.basic.BasicFileChooserUI()           }
      d["FormattedTextFieldUI"]    = { javax.swing.plaf.basic.BasicTextFieldUI()             }
      d["InternalFrameUI"]         = { javax.swing.plaf.basic.BasicInternalFrameUI()         }
      d["LabelUI"]                 = { javax.swing.plaf.basic.BasicLabelUI()                 }
      d["ListUI"]                  = { javax.swing.plaf.basic.BasicListUI()                  }
      d["MenuBarUI"]               = { javax.swing.plaf.basic.BasicMenuBarUI()               }
      d["MenuItemUI"]              = { javax.swing.plaf.basic.BasicMenuItemUI()              }
      d["OptionPaneUI"]            = { javax.swing.plaf.basic.BasicOptionPaneUI()            }
      d["PasswordFieldUI"]         = { javax.swing.plaf.basic.BasicPasswordFieldUI()         }
      d["PopupMenuUI"]             = { javax.swing.plaf.basic.BasicPopupMenuUI()             }
      d["ProgressBarUI"]           = { javax.swing.plaf.basic.BasicProgressBarUI()           }
      d["RadioButtonMenuItemUI"]   = { javax.swing.plaf.basic.BasicRadioButtonMenuItemUI()   }
      d["RadioButtonUI"]           = { javax.swing.plaf.basic.BasicRadioButtonUI()           }
      d["ScrollBarUI"]             = { javax.swing.plaf.basic.BasicScrollBarUI()             }
      d["ScrollPaneUI"]            = { javax.swing.plaf.basic.BasicScrollPaneUI()            }
      d["SeparatorUI"]             = { javax.swing.plaf.basic.BasicSeparatorUI()             }
      d["SliderUI"]                = { javax.swing.plaf.basic.BasicSliderUI()                }
      d["SpinnerUI"]               = { javax.swing.plaf.basic.BasicSpinnerUI()               }
      d["SplitPaneUI"]             = { javax.swing.plaf.basic.BasicSplitPaneUI()             }
      d["TabbedPaneUI"]            = { javax.swing.plaf.basic.BasicTabbedPaneUI()            }
      d["TableHeaderUI"]           = { javax.swing.plaf.basic.BasicTableHeaderUI()           }
      d["TableUI"]                 = { javax.swing.plaf.basic.BasicTableUI()                 }
      d["TextAreaUI"]              = { javax.swing.plaf.basic.BasicTextAreaUI()              }
      d["TextPaneUI"]              = { javax.swing.plaf.basic.BasicTextPaneUI()              }
      d["TextFieldUI"]             = { javax.swing.plaf.basic.BasicTextFieldUI()             }
      d["ToggleButtonUI"]          = { javax.swing.plaf.basic.BasicToggleButtonUI()          }
      d["ToolBarUI"]               = { javax.swing.plaf.basic.BasicToolBarUI()               }
      d["ToolTipUI"]               = { javax.swing.plaf.basic.BasicToolTipUI()               }
      d["TreeUI"]                  = { javax.swing.plaf.basic.BasicTreeUI()                  }
      return d
    }
  }
}
