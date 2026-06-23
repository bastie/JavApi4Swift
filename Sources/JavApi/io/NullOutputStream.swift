/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  /// A stream that discards all bytes written to it.
  /// - Since: Java 1.0
  internal class NullOutputStream : OutputStream {

    public override init() {
      super.init()
    }

    public override func write(_ b: Int) throws {
      // Do nothing
    }

    public override func write(_ b: UInt8) throws {
      // Do nothing
    }

    public override func write(_ buffer: [UInt8]) throws {
      // Do nothing
    }

    public override func write(_ buffer: [UInt8], _ offset: Int, _ length: Int) throws {
      // Do nothing
    }

    public override func flush() throws {
      // Do nothing
    }

    public override func close() throws {
      // Do nothing
    }
  }
}
