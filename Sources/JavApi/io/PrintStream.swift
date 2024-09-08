/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.io {
  open class PrintStream : OutputStream {// TODO: FilterOutputStream between PrintStream and OutputStream
    let delegate : OutputStream
    
    public init (_ newDelegate : OutputStream){
      self.delegate = newDelegate
    }
    
    public override func close() throws {
      try self.delegate.close()
    }
    public override func flush() throws {
      try self.delegate.flush ()
    }
    
    public override func write(_ value: [byte]) throws {
      try self.delegate.write(value)
    }
    
    public func print (_ s : String) {
      do {
        try self.write([UInt8] (s.data(using: .utf8)!))
      }
      catch {
        // ignored
      }
    }
    public func println (_ s : String) {
      let withLineBreak = s.appending("\n");
      do {
        try self.write([UInt8] (withLineBreak.data(using: .utf8)!))
      }
      catch {
        // ignored
      }
    }
  } // EOT
  
} // EOP
