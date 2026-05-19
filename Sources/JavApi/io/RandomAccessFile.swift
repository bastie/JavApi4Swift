/*
 * SPDX-FileCopyrightText: 2024-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  open class RandomAccessFile {
    
    let fileDescriptor : FileHandle
    let fileMode : String
    private var readBuffer = Data()      // aktueller Datenblock
    private var bufferPos = 0            // aktuelle Leseposition im Puffer
    private var bufferStartOffset: UInt64 = 0 // Dateioffset des ersten Bytes im Puffer

    /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
    public init (_ file : java.io.File, _ mode : String) throws (IOException) {
      if mode.contains("rw") {
        if let fd = FileHandle(forUpdatingAtPath : file.getAbsolutePath()) {
          self.fileDescriptor = fd
          self.fileMode = mode
        }
        else {
          throw java.io.IOException()
        }
      }
      else {
        if let fd = FileHandle(forReadingAtPath: file.getAbsolutePath()) {
          self.fileDescriptor = fd
          self.fileMode = mode
        }
        else {
          throw java.io.IOException()
        }
      }
    }
    
    /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
    public func getFD () throws -> java.io.FileDescriptor {
      return java.io.FileDescriptor(handle: fileDescriptor)
    }
    
    /// Setzt die Dateiposition. Setzt dabei den internen Lese-Puffer zurück.
    open func seek(_ newPos: Int64) throws (IOException) {
      do {
        try fileDescriptor.seek(toOffset: UInt64(newPos))
        // Puffer zurücksetzen, da wir an eine neue Stelle springen
        readBuffer = Data()
        bufferPos = 0
        bufferStartOffset = UInt64(newPos)
      } catch {
        throw java.io.IOException(error.localizedDescription)
      }
    }
    /// Close underlying file handle
    open func close () throws (IOException) {
      do {
        try self.fileDescriptor.close()
      }
      catch {
        throw java.io.IOException (error.localizedDescription)
      }
    }
    

    /// Gibt die aktuelle Dateiposition zurück (0-basiert).
    /// - Returns: Position in Bytes ab Dateianfang.
    open func getFilePointer() throws -> Int64 {
      // Tatsächliche Position = Startoffset des Puffers + aktueller Index im Puffer
      let pos = Int64(bufferStartOffset) + Int64(bufferPos)
      return pos
    }
    
    /// Liest die nächste Zeile aus der Datei.
    /// - Returns: Die Zeile ohne Zeilenumbruch, oder `nil` am Dateiende.
    /// - Throws: IOException bei Lesefehlern oder Kodierungsfehlern.
    open func readLine() throws -> String? {
      var lineData = Data()
      var foundNewline = false
      var hitEOF = false
      
      
      while !foundNewline {
        // Puffer nachfüllen, falls nötig
        if bufferPos >= readBuffer.count {
          // Neuen Block lesen (Standardgröße 4096 Bytes, anpassbar)
          let blockSize = 4096
          let newData = try fileDescriptor.read(upToCount: blockSize) ?? Data()
          if newData.isEmpty {
            hitEOF = true
            break   // keine weiteren Daten
          }
          readBuffer = newData
          bufferPos = 0
          bufferStartOffset = try fileDescriptor.offset() - UInt64(newData.count)
        }
        
        // Suche im aktuellen Puffer nach Zeilenumbruch
        for i in bufferPos..<readBuffer.count {
          let byte = readBuffer[i]
          if byte == 0x0A { // LF (\n)
                            // Zeile ohne LF anhängen
            if i > bufferPos {
              lineData.append(readBuffer.subdata(in: bufferPos..<i))
            }
            bufferPos = i + 1
            foundNewline = true
            break
          } else if byte == 0x0D { // CR (\r)
                                   // Zeile ohne CR anhängen
            if i > bufferPos {
              lineData.append(readBuffer.subdata(in: bufferPos..<i))
            }
            bufferPos = i + 1
            
            // Prüfen, ob ein LF folgt (CRLF)
            if bufferPos < readBuffer.count && readBuffer[bufferPos] == 0x0A {
              bufferPos += 1   // LF überspringen
            } else if bufferPos == readBuffer.count && !hitEOF {
              // CR am Ende des Puffers: wir müssen ein Byte vorauslesen
              let nextByte = try readOneByteAfterCurrentBlock()
              if nextByte == 0x0A {
                // CRLF erkannt, kein weiteres Byte zur Zeile hinzufügen
                // bufferPos wurde bereits auf readBuffer.count gesetzt, bleibt so
              }
            }
            foundNewline = true
            break
          }
        }
        
        // Falls kein Zeilenumbruch im gesamten Puffer gefunden wurde,
        // den kompletten Puffer an lineData anhängen und nächsten Block laden.
        if !foundNewline && bufferPos < readBuffer.count {
          let remaining = readBuffer.subdata(in: bufferPos..<readBuffer.count)
          lineData.append(remaining)
          bufferPos = readBuffer.count
        }
      }
      
      // Am Dateiende: die letzte Zeile ohne abschließenden Zeilenumbruch zurückgeben
      if !foundNewline && hitEOF {
        return lineData.isEmpty ? nil : try decode(lineData)
      }
      
      return try decode(lineData)
    }
    
    // MARK: - Private Hilfsmethoden
    
    private func decode(_ data: Data) throws (IOException) -> String {
      guard let string = String(data: data, encoding: .utf8) else {
        throw java.io.IOException("Invalid UTF-8 sequence")
      }
      return string
    }
    
    /// Liest ein einzelnes Byte über das aktuelle Pufferende hinaus, ohne den Puffer zu zerstören.
    private func readOneByteAfterCurrentBlock() throws -> UInt8? {
      let nextData = try fileDescriptor.read(upToCount: 1)
      guard let byte = nextData?.first else { return nil }
      if byte != 0x0A {
        // Gehört zur nächsten Zeile → zurückspringen
        let pos = try fileDescriptor.offset()
        try fileDescriptor.seek(toOffset: pos - 1)
      }
      // LF → einfach konsumiert lassen
      return byte
    }
  }
}

