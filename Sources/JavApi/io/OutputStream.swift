/*
 * SPDX-FileCopyrightText: 2023, 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.io {
  open class OutputStream : java.io.Flushable, java.io.Closeable {
    public typealias Flushable = OutputStream
    public typealias Closeable = OutputStream
    
    /// Default constructor
    public init(){}
    
    open func close() throws {
    }
    
    open func flush() throws {
    }
    
    open func write (_ b : Int) throws {
      fatalError("not yet implemented")
    }
    open func write (_ b : UInt8) throws {
      fatalError("not yet implemented")
    }
    open func write (_ value : [byte]) throws {
      fatalError("not yet implemented")
    }
    
    open func write (_ buffer : [UInt8], _ pos : Int, _ length : Int) throws {
      fatalError("not yet implemented")
    }

    // TODO: TEST required
    public static func nullOutputStream () -> OutputStream {
      let result = OutputStream()
      return result;
    }
  }
}
