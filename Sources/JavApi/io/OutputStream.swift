/*
 * SPDX-FileCopyrightText: 2023, 204 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.io {
  open class OutputStream : java.io.Flushable, java.io.Closeable {
    public typealias Flushable = OutputStream
    public typealias Closeable = OutputStream
    
    public func close() throws {
    }
    
    public func flush() {
    }
    
    public func write (_ b : Int) {
      fatalError("not yet implemented")
    }
    public func write (_ b : UInt8) {
      fatalError("not yet implemented")
    }
    public func write (_ value : [byte]) {
      fatalError("not yet implemented")
    }
    
    public func write (_ buffer : [UInt8], _ pos : Int, _ length : Int) {
      fatalError("not yet implemented")
    }

    // TODO: TEST required
    public static func nullOutputStream () -> OutputStream {
      let result = OutputStream()
      return result;
    }
  }
}
