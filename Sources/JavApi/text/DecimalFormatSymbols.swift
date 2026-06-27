/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.text {

  /// Encapsulates the locale-sensitive symbols used by ``DecimalFormat``.
  ///
  /// Obtain an instance via the factory method ``getInstance(_:)`` or the
  /// initialisers.  All symbols can be overridden individually after creation.
  ///
  /// - Since: Java 1.1
  open class DecimalFormatSymbols {

    // -------------------------------------------------------------------------
    // MARK: Stored symbols
    // -------------------------------------------------------------------------

    private var _decimalSeparator:   Character
    private var _groupingSeparator:  Character
    private var _minusSign:          Character
    private var _percent:            Character
    private var _perMill:            Character
    private var _zeroDigit:          Character
    private var _digit:              Character    // '#' placeholder in patterns
    private var _patternSeparator:   Character    // ';' between pos/neg sub-patterns
    private var _infinity:           String
    private var _naN:                String
    private var _currencySymbol:     String
    private var _internationalCurrencySymbol: String
    private var _monetaryDecimalSeparator: Character
    private var _exponentSeparator:  String

    // -------------------------------------------------------------------------
    // MARK: Initialisers
    // -------------------------------------------------------------------------

    /// Creates symbols for the default locale.
    public convenience init() {
      self.init(java.util.Locale.getDefault())
    }

    /// Creates symbols for `locale`.
    public init(_ locale: java.util.Locale) {
      let foundation = locale.delegate ?? Foundation.Locale.current

      _decimalSeparator  = Character(foundation.decimalSeparator  ?? ".")
      _groupingSeparator = Character(foundation.groupingSeparator ?? ",")
      _minusSign         = "-"
      _percent           = "%"
      _perMill           = "\u{2030}"
      _zeroDigit         = "0"
      _digit             = "#"
      _patternSeparator  = ";"
      _infinity          = "\u{221E}"   // ∞
      _naN               = "NaN"
      _currencySymbol    = foundation.currencySymbol ?? "\u{00A4}"
      _internationalCurrencySymbol = foundation.currency?.identifier ?? "XXX"
      _monetaryDecimalSeparator = Character(foundation.decimalSeparator ?? ".")
      _exponentSeparator = "E"
    }

    // -------------------------------------------------------------------------
    // MARK: Factory
    // -------------------------------------------------------------------------

    /// Returns a `DecimalFormatSymbols` for the default locale.
    public static func getInstance() -> DecimalFormatSymbols {
      return DecimalFormatSymbols(java.util.Locale.getDefault())
    }

    /// Returns a `DecimalFormatSymbols` for `locale`.
    public static func getInstance(_ locale: java.util.Locale) -> DecimalFormatSymbols {
      return DecimalFormatSymbols(locale)
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getDecimalSeparator()  -> Character { _decimalSeparator  }
    public func setDecimalSeparator(_ c: Character)  { _decimalSeparator  = c }

    public func getGroupingSeparator() -> Character { _groupingSeparator }
    public func setGroupingSeparator(_ c: Character) { _groupingSeparator = c }

    public func getMinusSign()         -> Character { _minusSign         }
    public func setMinusSign(_ c: Character)         { _minusSign         = c }

    public func getPercent()           -> Character { _percent           }
    public func setPercent(_ c: Character)           { _percent           = c }

    public func getPerMill()           -> Character { _perMill           }
    public func setPerMill(_ c: Character)           { _perMill           = c }

    public func getZeroDigit()         -> Character { _zeroDigit         }
    public func setZeroDigit(_ c: Character)         { _zeroDigit         = c }

    public func getDigit()             -> Character { _digit             }
    public func setDigit(_ c: Character)             { _digit             = c }

    public func getPatternSeparator()  -> Character { _patternSeparator  }
    public func setPatternSeparator(_ c: Character)  { _patternSeparator  = c }

    public func getInfinity()          -> String    { _infinity          }
    public func setInfinity(_ s: String)             { _infinity          = s }

    public func getNaN()               -> String    { _naN               }
    public func setNaN(_ s: String)                  { _naN               = s }

    public func getCurrencySymbol()    -> String    { _currencySymbol    }
    public func setCurrencySymbol(_ s: String)       { _currencySymbol    = s }

    public func getInternationalCurrencySymbol() -> String { _internationalCurrencySymbol }
    public func setInternationalCurrencySymbol(_ s: String) { _internationalCurrencySymbol = s }

    public func getMonetaryDecimalSeparator() -> Character { _monetaryDecimalSeparator }
    public func setMonetaryDecimalSeparator(_ c: Character) { _monetaryDecimalSeparator = c }

    public func getExponentSeparator() -> String    { _exponentSeparator }
    public func setExponentSeparator(_ s: String)   { _exponentSeparator = s }
  }
}
