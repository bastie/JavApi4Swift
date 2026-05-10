/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

open class ThreadDeath : JError, @unchecked Sendable {
  
  public override init () {
    super.init()
  }
}
