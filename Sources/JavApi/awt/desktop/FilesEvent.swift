/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.desktop {
  
  /// - Since: Java 9
  open class FilesEvent : AppEvent, @unchecked Sendable {
    
    private let files : any java.util.List<java.io.File>
    
    internal init(_ files : any java.util.List<java.io.File>) {
      self.files = files
      super.init()
    }
    
    public func getFiles () -> any java.util.List<java.io.File> {
      return files
    }
  }
}
