/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {
  open class EmptyStackException : RuntimeException, @unchecked Sendable {
    
    public override init () {
      super.init()
    }
  }
}
