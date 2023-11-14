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

