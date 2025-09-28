/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
#if canImport(Network)
import Network
#endif

extension java.io {
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  public final class FileDescriptor {
    
    // TODO: file and socket need to be implemented
    
    /// handle for file
    internal var fileHandle: FileHandle?
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public init () {}
    
    internal init (handle: FileHandle){
      self.fileHandle = handle
    }
    
#if canImport(Network)
    private var connection: NWConnection?
    internal init (handle: NWConnection){
      self.connection = handle
    }
#endif // canImport(Network)

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
#if canImport(Network)
      if let connection {
        switch connection.state {
          case .ready : return true
          default : return false
        }
      }
#endif // canImport(Network)
      return false
    }
  }
}
