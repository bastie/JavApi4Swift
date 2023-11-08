/*
 * SPDX-FileCopyrightText: 2015 - Doug Richardson
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Unlicense
 */

extension java.util {
  
  //
  //  Base64.swift
  //  SwiftyBase64
  //
  //  Created by Doug Richardson on 8/7/15.
  //  Modify ⁴JavApi by Sebastian Ritter
  //
  
  ///
  /// Base64 Alphabet to use during encoding.
  ///
  /// - Standard: The standard Base64 encoding, defined in RFC 4648 section 4.
  /// - URLAndFilenameSafe: The base64url encoding, defined in RFC 4648 section 5.
  ///
  public enum Alphabet {
    /// The standard Base64 alphabet
    case Standard
    
    /// The URL and Filename Safe Base64 alphabet
    case URLAndFilenameSafe
  }
  
  /// Base64 implementation
  open class Base64 {
    
    public static func getEncoder () -> Encoder {
      return Encoder(.Standard)
    }
    
    public static func getURLEncoder () -> Encoder {
      return Encoder(.URLAndFilenameSafe)
    }
    /// Get the encoding table for the alphabet.
    static func tableForAlphabet(_ alphabet : Alphabet) -> [UInt8] {
      switch alphabet {
      case .Standard:
        return StandardAlphabet
      case .URLAndFilenameSafe:
        return URLAndFilenameSafeAlphabet
      }
    }
    
  }
}

