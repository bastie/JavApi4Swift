/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.io {
  open class PrintStream : FilterOutputStream {

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
