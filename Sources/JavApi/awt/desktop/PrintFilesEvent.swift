/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.desktop {
  
  /// - Since: Java 9
  public final class PrintFilesEvent : FilesEvent, @unchecked Sendable {
    
    public override init(_ files : any java.util.List<java.io.File>) {
      super.init(files)
    }
  }
}
