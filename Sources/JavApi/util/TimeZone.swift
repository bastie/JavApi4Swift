/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  public protocol TimeZone {
    var delegate : Foundation.TimeZone { get set }
    /// Returns the timezone ID as passed to the constructor (Java contract).
    func getID() -> String
    /// Returns the raw UTC offset in milliseconds (without DST).
    func getRawOffset() -> Int
  }
}

extension java.util.TimeZone {

  static func getAvailableIDs () -> [String] {
    return Foundation.TimeZone.knownTimeZoneIdentifiers
  }

  static func getAvailableIDs (_ rawOffset : Int) -> [String] {
    let secondsFromGMT = rawOffset / 1000
    return Foundation.TimeZone.knownTimeZoneIdentifiers.filter { id in
      Foundation.TimeZone(identifier: id)?.secondsFromGMT() == secondsFromGMT
    }
  }

  /// Returns the default `TimeZone` for this host, as a `SimpleTimeZone`.
  static func getDefault () -> any java.util.TimeZone {
    let tz = Foundation.TimeZone.current
    return java.util.SimpleTimeZone(tz.secondsFromGMT() * 1000, tz.identifier)
  }

  /// Returns the `TimeZone` with the given ID, or GMT if the ID is unknown.
  ///
  /// Matches Java's contract: the returned zone's `getID()` equals the
  /// requested `id` string (e.g. `getTimeZone("UTC").getID() == "UTC"`),
  /// even if Foundation internally maps the identifier to an equivalent name.
  /// For unknown IDs Java returns GMT — we do the same.
  static func getTimeZone (_ id: String) -> any java.util.TimeZone {
    if let tz = Foundation.TimeZone(identifier: id) ?? Foundation.TimeZone(abbreviation: id) {
      // Preserve the originally requested ID, matching Java's contract.
      return java.util.SimpleTimeZone(tz.secondsFromGMT() * 1000, id)
    } else {
      // Unknown ID → GMT, as Java specifies.
      return java.util.SimpleTimeZone(0, "GMT")
    }
  }

  func getID () -> String {
    return delegate.identifier
  }

  /// Raw UTC offset in milliseconds (without DST).
  func getRawOffset () -> Int {
    return delegate.secondsFromGMT() * 1000
  }
}

// SimpleTimeZone is defined in SimpleTimeZone.swift
