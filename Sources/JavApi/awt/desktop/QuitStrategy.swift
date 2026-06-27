/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.desktop {
  
  /// - Since: Java 9
  public enum QuitStrategy : Enum, @unchecked Sendable {
    public typealias E = QuitStrategy

    case CLOSE_ALL_WINOWS
    case NORMAL_EXIT
    
  }
}
