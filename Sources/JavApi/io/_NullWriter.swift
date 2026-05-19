/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  
  // see JavaDoc to nullWriter method in class java.io.PrintWriter for description
  internal final class NullWriter : java.io.PrintWriter {
    
    private var isOpen : Bool = true
    
    public init() {
      super.init(java.io.OutputStream.nullOutputStream(), false)
    }
    public override func append(_ c: Character) throws -> any Appendable {
      if isOpen {
        return self
      }
      throw IOException("Stream closed")
    }
    public override func append(_ csq: any CharSequence) throws -> any Appendable {
      if isOpen {
        return self
      }
      throw IOException("Stream closed")
    }
    public override func append(_ csq: any CharSequence, _ start: Int, _ end: Int) throws -> any Appendable {
      if isOpen {
        return self
      }
      throw IOException("Stream closed")
    }
    public override func write(_ intWert: Int) throws {
      if !isOpen {
        throw IOException("Stream closed")
      }
    }
    public override func write(_ buf: [Character]) throws {
      if !isOpen {
        throw IOException("Stream closed")
      }
    }
    public override func write(_ buf: [Character], _ offset: Int, _ count: Int) throws {
      if !isOpen {
        throw IOException("Stream closed")
      }
    }
    public override func close() {
      isOpen = false
    }
  }
}
