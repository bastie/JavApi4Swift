/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Helpertype to work only with console default input stream and default output stream.
///
/// - Since: Java 25
public struct IO {
  /// Print string on `System.out`
  /// - Parameter string: output string
  public static func println (_ string: String) {
    System.out.println(string)
  }
  
  /// Print line separator on `System.out`
  public static func println () {
    System.out.println("")
  }
  
  /// Print a string representation of given parameter
  /// - Parameter o: type to print
  public static func print (_ o: Any) {
    System.out.println("\(o)")
  }
  
  /// Read next line from `System.in`
  /// - Returns: readed line or nil
  public static func readln () throws  -> String? {
    do {
      return try java.io.BufferedReader(java.io.InputStreamReader(System.in)).readLine()
    }
    catch {
      throw java.io.IOError(error.localizedDescription)
    }
  }
  
  /// Print a prompt on `System.out` and then read line from `System.in`
  /// - Parameter prompt: prompt input before read line
  /// - Returns: readed line or nil
  public static func readln (_ prompt : String?) throws -> String? {
    let prompt = prompt ?? ""
    IO.print(prompt)
    return try readln()
  }
}
