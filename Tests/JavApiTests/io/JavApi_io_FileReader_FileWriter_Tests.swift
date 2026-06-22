/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

struct JavApi_io_FileReader_Tests {

  // MARK: - Hilfsfunktionen

  /// Legt eine temporäre Datei mit dem angegebenen Inhalt an und gibt den Pfad zurück.
  private func makeTempFile(_ content: String) throws -> String {
    let path = FileManager.default.temporaryDirectory
      .appendingPathComponent("javapi_test_\(UUID().uuidString).txt").path
    try content.write(toFile: path, atomically: true, encoding: .utf8)
    return path
  }

  // MARK: - Initialisierung

  @Test("FileReader(String) öffnet existierende Datei")
  func initWithPath() throws {
    let path = try makeTempFile("hello")
    let reader = try java.io.FileReader(path)
    try reader.close()
  }

  @Test("FileReader(String) wirft FileNotFoundException für nicht existierende Datei")
  func initWithMissingPathThrows() throws {
    #expect(throws: (any Error).self) {
      _ = try java.io.FileReader("/this/does/not/exist/ever.txt")
    }
  }

  @Test("FileReader(File) öffnet existierende Datei")
  func initWithFile() throws {
    let path = try makeTempFile("world")
    let file = java.io.File(path)
    let reader = try java.io.FileReader(file)
    try reader.close()
  }

  @Test("FileReader(File) wirft FileNotFoundException für nicht existierende Datei")
  func initWithMissingFileThrows() throws {
    let file = java.io.File("/this/does/not/exist/ever.txt")
    #expect(throws: (any Error).self) {
      _ = try java.io.FileReader(file)
    }
  }

  // MARK: - read()

  @Test("read() liest ASCII-Zeichen Schritt für Schritt")
  func readCharByChar() throws {
    let path = try makeTempFile("AB")
    let reader = try java.io.FileReader(path)
    defer { try? reader.close() }

    #expect(try reader.read() == Int(Character("A").unicodeScalars.first!.value))
    #expect(try reader.read() == Int(Character("B").unicodeScalars.first!.value))
    #expect(try reader.read() == -1)
  }

  @Test("read() liest UTF-8 Text vollständig")
  func readFullContent() throws {
    let original = "Hello, World!"
    let path = try makeTempFile(original)
    let reader = try java.io.FileReader(path)
    defer { try? reader.close() }

    var result = ""
    var ch = try reader.read()
    while ch != -1 {
      if let scalar = Unicode.Scalar(ch) {
        result.append(Character(scalar))
      }
      ch = try reader.read()
    }
    #expect(result == original)
  }

  // MARK: - read über BufferedReader

  @Test("FileReader über BufferedReader liest Zeilen korrekt")
  func readLinesViaBufferedReader() throws {
    let path = try makeTempFile("line1\nline2\nline3")
    let fr = try java.io.FileReader(path)
    let br = java.io.BufferedReader(fr)
    defer { try? br.close() }

    #expect(try br.readLine() == "line1")
    #expect(try br.readLine() == "line2")
    #expect(try br.readLine() == "line3")
    #expect(try br.readLine() == nil)
  }

  // MARK: - close()

  @Test("Nach close() wirft read() IOException")
  func readAfterCloseThrows() throws {
    let path = try makeTempFile("x")
    let reader = try java.io.FileReader(path)
    try reader.close()
    #expect(throws: (any Error).self) {
      _ = try reader.read()
    }
  }
}

struct JavApi_io_FileWriter_Tests {

  // MARK: - Hilfsfunktionen

  private func tempPath() -> String {
    return FileManager.default.temporaryDirectory
      .appendingPathComponent("javapi_test_\(UUID().uuidString).txt").path
  }

  private func readFile(_ path: String) throws -> String {
    return try String(contentsOfFile: path, encoding: .utf8)
  }

  // MARK: - Initialisierung

  @Test("FileWriter(String) erstellt neue Datei")
  func initWithPathCreatesFile() throws {
    let path = tempPath()
    let writer = try java.io.FileWriter(path)
    try writer.close()
    #expect(FileManager.default.fileExists(atPath: path))
    try? FileManager.default.removeItem(atPath: path)
  }

  @Test("FileWriter(File) erstellt neue Datei")
  func initWithFileCreatesFile() throws {
    let path = tempPath()
    let file = java.io.File(path)
    let writer = try java.io.FileWriter(file)
    try writer.close()
    #expect(FileManager.default.fileExists(atPath: path))
    try? FileManager.default.removeItem(atPath: path)
  }

  // MARK: - write(String)

  @Test("write(String) schreibt Inhalt korrekt")
  func writeString() throws {
    let path = tempPath()
    let writer = try java.io.FileWriter(path)
    try writer.write("Hello, FileWriter!")
    try writer.close()
    let content = try readFile(path)
    #expect(content == "Hello, FileWriter!")
    try? FileManager.default.removeItem(atPath: path)
  }

  @Test("write(String) mit UTF-8 Sonderzeichen")
  func writeStringWithSpecialChars() throws {
    let path = tempPath()
    let original = "Grüße & Ümlaute"
    let writer = try java.io.FileWriter(path)
    try writer.write(original)
    try writer.close()
    let content = try readFile(path)
    #expect(content == original)
    try? FileManager.default.removeItem(atPath: path)
  }

  // MARK: - Roundtrip mit FileReader

  @Test("FileWriter → FileReader Roundtrip")
  func roundtrip() throws {
    let path = tempPath()
    let original = "Roundtrip Test: äöü"

    let writer = try java.io.FileWriter(path)
    try writer.write(original)
    try writer.close()

    let reader = try java.io.FileReader(path)
    var result = ""
    var ch = try reader.read()
    while ch != -1 {
      if let scalar = Unicode.Scalar(ch) {
        result.append(Character(scalar))
      }
      ch = try reader.read()
    }
    try reader.close()

    #expect(result == original)
    try? FileManager.default.removeItem(atPath: path)
  }

  // MARK: - Überschreiben

  @Test("FileWriter überschreibt bestehende Datei")
  func overwritesExistingFile() throws {
    let path = tempPath()
    try "old content".write(toFile: path, atomically: true, encoding: .utf8)

    let writer = try java.io.FileWriter(path)
    try writer.write("new content")
    try writer.close()

    let content = try readFile(path)
    #expect(content == "new content")
    try? FileManager.default.removeItem(atPath: path)
  }

  // MARK: - close()

  @Test("Nach close() wirft write() IOException")
  func writeAfterCloseThrows() throws {
    let path = tempPath()
    let writer = try java.io.FileWriter(path)
    try writer.close()
    #expect(throws: (any Error).self) {
      try writer.write("x")
    }
    try? FileManager.default.removeItem(atPath: path)
  }
}
