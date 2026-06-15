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
      d["LabelUI"]        = { javax.swing.plaf.basic.BasicLabelUI()        }
      d["MenuBarUI"]      = { javax.swing.plaf.basic.BasicMenuBarUI()      }
      d["PopupMenuUI"]    = { javax.swing.plaf.basic.BasicPopupMenuUI()    }
      d["RadioButtonUI"]  = { javax.swing.plaf.basic.BasicRadioButtonUI()  }
      d["ToggleButtonUI"] = { javax.swing.plaf.basic.BasicToggleButtonUI() }
      return d
    }
  }
}
