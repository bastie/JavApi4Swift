/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension System {
  
  /// Printstream to write on standard output.
  public static var out : SystemOut {
    get {
      return SystemOut ()
    }
  }
  
  /// Internal PrintStream to write on standard OutputStream
  public class SystemOut : java.io.PrintStream {
    init () {
      super.init(java.io.OutputStream.nullOutputStream())
    }
    
    public override func write(_ b: Int) {
      Swift.print (b, terminator: "")
    }
    public override func write(_ b: UInt8) {
      Swift.print (b, terminator: "")
    }
    
    public override func write(_ value: [byte]) {
      Swift.print (String(decoding: Data(value), as: UTF8.self))
    }
    
    public override func println(_ s: String) {
      Swift.print(s)
    }
    public override func print(_ s: String) {
      Swift.print(s, terminator: "")
    }
  }
}
