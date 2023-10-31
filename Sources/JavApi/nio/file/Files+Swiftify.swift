/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.nio.file.Files {
  
  /// Read all byte of a file and return a byte array.
  /// - Parameter file path
  /// - Returns byte array
  /// - Throws OutOfMemoryError if file is to large or IOException on error
  public static func readAllBytes (_ file : Path) throws -> Data {
    let lengthOfFile = java.io.File(file.toString()).length()
    guard 0 < lengthOfFile else {
      return Data([UInt8]())
    }
    guard Int.max > lengthOfFile else {
      throw Throwable.OutOfMemoryError ("OutOfMemoryError: file with \(lengthOfFile) to big to read fully into an array")
    }
    do {
      if #available(macOS 13.0, *) {
        return try Data(contentsOf: URL(filePath: file.toString()))
      } else {
        // TODO: Fallback on earlier versions
      }
    }
    catch {
      throw java.io.Throwable.IOException("IOException: file \(file.toString()) can not be reading ")
    }
    throw java.io.Throwable.IOException("IOException: file \(file.toString()) can not be reading ")
  }
  
}
