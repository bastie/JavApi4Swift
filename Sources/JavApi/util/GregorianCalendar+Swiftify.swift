/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.GregorianCalendar {
  
  // Java autoconvert Int types
  public convenience init (_ happyNewYear : any FixedWidthInteger, _ newMonth : any FixedWidthInteger, _ newDayOfMonth : any FixedWidthInteger, _ newHourOfDay : any FixedWidthInteger, _ newMinute : any FixedWidthInteger, _ newSecond : any FixedWidthInteger) {
    self.init(Int(happyNewYear), Int(newMonth), Int(newDayOfMonth), Int(newHourOfDay), Int(newMinute), Int(newSecond))
  }
  
  
  
  public func get (_ what : java.util.Calender.DateComponents) -> Int {
    return try! self.get(what.rawValue)
  }
}

