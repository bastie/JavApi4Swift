/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {
  
  /// - Since: Java 1.4
  open class Handler {
    
    public init() {
    }
    
    private var level : Level = Level.INFO
    
    open func setLevel(_ newLevel: Level) {
      self.level = newLevel
    }
    
    open func getLevel() -> Level {
      return self.level
    }
    
  }
}
