/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// `Comparable` type in Java
public protocol ComparableJ : Comparable {
  
  func compareTo (_ other : ComparableJ?) throws -> Int
  
  associatedtype ComparableJ : java.lang.Comparable
}

