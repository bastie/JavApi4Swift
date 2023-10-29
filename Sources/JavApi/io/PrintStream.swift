/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.io {
  public class PrintStream : OutputStream {// TODO: FilterOutputStream between PrintStream and OutputStream
    let delegate : OutputStream
    
    public init (_ newDelegate : OutputStream){
      self.delegate = newDelegate
    }
    
    public override func close() throws {
      try self.delegate.close()
    }
    public override func flush() {
      self.delegate.flush ()
    }
    
    public override func write(_ value: [byte]) {
      self.delegate.write(value)
    }
    
    public func print (_ s : String) {
      self.write([UInt8] (s.data(using: .utf8)!))
    }
    public func println (_ s : String) {
      let withLineBreak = s.appending("\n");
      self.write([UInt8] (withLineBreak.data(using: .utf8)!))
    }
  } // EOT
  
} // EOP
