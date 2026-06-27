/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.desktop {
  
  /// - Since: Java 9
  public final class OpenFilesEvent : FilesEvent, @unchecked Sendable {
    
    private let searchTerm : String
    
    public init(_ files : any java.util.List<java.io.File>, _ searchTerm : String) {
      self.searchTerm = searchTerm
      super.init(files)
    }
    
    public func getSearchTerm() -> String {
      return searchTerm
    }
  }
}
