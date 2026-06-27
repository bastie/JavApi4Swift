/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.desktop {
  
  open class AppEvent : java.util.EventObject, @unchecked Sendable {
    public init() {
      let source = {
        do {
          return try Desktop.getDesktop()
        }
        catch _ {
          var invalidDesktop = Desktop()
          invalidDesktop.isValid = false
          return invalidDesktop
        }
      }()
      super.init(source)
    }
  }
}
