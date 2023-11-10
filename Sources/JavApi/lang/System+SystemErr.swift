/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension System {
  
  /// Printstream to write on standard output.
  public static var err : SystemErr {
    get {
      return SystemErr ()
    }
  }
  
  /// Internal PrintStream to write on standard ErrorStream, wand not using import Darwin
  public class SystemErr : java.io.PrintStream {
    
    let err = FileHandle.standardError
    
    init () {
      super.init(java.io.OutputStream.nullOutputStream())
    }
    
    public override func write(_ b: Int) {
      err.print ("\(b)")
    }
    public override func write(_ b: UInt8) {
      self.write([b])
    }
    
    public override func write(_ value: [byte]) {
      err.print (String(decoding: Data(value), as: UTF8.self))
    }
    
    public override func println(_ s: String) {
      err.println(s)
    }
    public override func print(_ s: String) {
      err.print(s)
    }
  }
}
