/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.nio.file {

  /// Utility type for working with files
  public class Files {
    
    /// Write data to given file
    ///
    /// The default `option` is `StandardOpenOption.WRITE`.
    ///
    /// - Parameters:
    ///     - file to write into
    ///     - bytes as the write content
    ///     - option how to write
    public static func write (_ file : Path, _ bytes : [UInt8], _ option : OpenOption = StandardOpenOption.WRITE) throws -> Path{
      if FileManager.default.fileExists(atPath: file.toString()) {
        if let fileHandle = FileHandle(forWritingAtPath: file.toString()) {
          // seekToEndOfFile, writes data at the last of file(appends not override)
          fileHandle.seekToEndOfFile()
          fileHandle.write(Data(bytes))
          fileHandle.closeFile()
        }
        else {
          throw java.io.Throwable.IOException("IOException: file can not be written at \(file.toString())")
        }
      }
      else {
        // if file does not exist write data for the first time
        do{
          if #available(macOS 13.0, *) {
            try Data(bytes).write(to: URL(filePath: file.toString()), options: .atomic)
          } else {
            throw java.io.Throwable.IOException("IOException: func Files.write (Path, [UInt8], OpenOption not yet implemented for other than macOS 13.0 or higher. Please help!")
          }
        }catch {
          throw java.io.Throwable.IOException("IOException: file \(file.toString()) can not be created and written")
        }
      }
      return file
    }
    
    /// Read all byte of a file and return a byte array.
    /// - Parameter file path
    /// - Returns byte array
    /// - Throws OutOfMemoryError if file is to large or IOException on error
    public static func readAllBytes (_ file : Path) throws -> [UInt8] {
      let lengthOfFile = java.io.File(file.toString()).length()
      guard 0 < lengthOfFile else {
        return [UInt8]()
      }
      guard Int.max > lengthOfFile else {
        throw Throwable.OutOfMemoryError ("OutOfMemoryError: file with \(lengthOfFile) to big to read fully into an array")
      }
      do {
        if #available(macOS 13.0, *) {
          return [UInt8] (try Data(contentsOf: URL(filePath: file.toString())))
        } else {
          // TODO: Fallback on earlier versions
        }
      }
      catch {
        throw java.io.Throwable.IOException("IOException: file \(file.toString()) can not be reading ")
      }
      throw java.io.Throwable.IOException("IOException: file \(file.toString()) can not be reading ")
    }
   
    @available(macOS 13.0, *)
    public static func write (_ file : java.nio.file.Path, _ content : [UInt8], _ options : java.nio.file.OpenOption? = nil) throws {
      if let options {
        // FIXME: not yet implemented
        fatalError("not yet implemented \(options)")
      }
      else {
        // Javadoc tells us: In other words, it opens the file for writing, creating the file if it doesn't exist, or initially truncating an existing regular-file to a size of 0.
        var b = file.toFile().exists()
        if (b) {
          b = file.toFile().delete()
        }
        do {
          try Data(content).write(to: URL(filePath: file.toString()))
        }
        catch {
          throw java.io.Throwable.IOException(error.localizedDescription)
        }
      }
    }

  }
}
