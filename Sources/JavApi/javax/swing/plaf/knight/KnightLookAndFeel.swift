/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// Das Knight Look & Feel ist ein Beispiel Look & Feel
  ///
  /// `KnightLookAndFeel` Register Fabrik für alle implementierten
  /// component-UI Klasses in `javax.swing.plaf.knight`.
  ///
  @MainActor
  open class KnightLookAndFeel: javax.swing.LookAndFeel {

    public override init() {}

    override open func getName()        -> String { "Knight" }
    override open func getID()          -> String { "DarkKnight" }
    override open func getDescription() -> String {
      if java.util.Locale.getDefault().getLanguage().equals("de") == true {
        return "Schwarzer Ritter Look & Feel"
      }
      else {
        return "Dark Knight Look & Feel"
      }
    }
    override open func isNativeLookAndFeel()    -> Bool { false }
    override open func isSupportedLookAndFeel() -> Bool { true  }

    override open func getDefaults() -> javax.swing.UIDefaults {
      let d = javax.swing.UIDefaults()
      d["ButtonUI"]       = { javax.swing.plaf.basic.BasicButtonUI()       }
      d["ColorChooserUI"] = { javax.swing.plaf.basic.BasicColorChooserUI() }
      d["DesktopPaneUI"]  = { javax.swing.plaf.basic.BasicDesktopPaneUI()  }
      d["FileChooserUI"]  = { javax.swing.plaf.basic.BasicFileChooserUI()  }
      d["OptionPaneUI"]   = { javax.swing.plaf.basic.BasicOptionPaneUI()   }
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
      d["TextPaneUI"]     = { javax.swing.plaf.basic.BasicTextPaneUI()     }
      d["EditorPaneUI"]   = { javax.swing.plaf.basic.BasicTextPaneUI()     }
      d["TextFieldUI"]    = { javax.swing.plaf.basic.BasicTextFieldUI()    }
      d["SplitPaneUI"]    = { javax.swing.plaf.basic.BasicSplitPaneUI()    }
      d["ToggleButtonUI"] = { javax.swing.plaf.basic.BasicToggleButtonUI() }
      d["TreeUI"]         = { javax.swing.plaf.basic.BasicTreeUI()         }
      d["TableUI"]        = { javax.swing.plaf.basic.BasicTableUI()        }
      d["TableHeaderUI"]  = { javax.swing.plaf.basic.BasicTableHeaderUI()  }
      d["ProgressBarUI"]  = { javax.swing.plaf.basic.BasicProgressBarUI()  }
      d["SliderUI"]       = { javax.swing.plaf.basic.BasicSliderUI()       }
      return d
    }
  }
}
