/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {
  open class Collections {
    
    public static func emptySet<Element>() -> Set<Element> {
      return Swift.Set<Element>()
    }
  }
}
