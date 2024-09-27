/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
import Network

extension java.io {
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  public final class FileDescriptor {
    
    // TODO: file and socket need to be implemented
    
    /// handle for file
    internal var fileHandle: FileHandle?
    
    private var connection: NWConnection?
    
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public init () {}
    
    internal init (handle: FileHandle){
      self.fileHandle = handle
    }
    
    internal init (handle: NWConnection){
      self.connection = handle
    }
    
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public func valid () -> Bool{
      if let fileHandle {
        do {
          let _ = try fileHandle.offset()
        }
        catch {
          return false
        }
      }
      if let connection {
        switch connection.state {
          case .ready : return true
          default : return false
        }
      }
      return false
    }
  }
}
