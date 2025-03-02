/*
 * SPDX-FileCopyrightText: 2023, 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java {
  /// The Java base class implementation
  public enum lang{}
}

// types to place in default namespace like Java
extension java.lang {
  public typealias Array = Swift.Array
  public typealias Cloneable = JavApi.Cloneable
  public typealias Comparable = JavApi.ComparableJ
  public typealias Exception = JavApi.Throwable
  public typealias Runnable = JavApi.Runnable
  public typealias System = JavApi.System
  public typealias String = Swift.String
  public typealias StringBuilder = JavApi.StringBuilder
  public typealias Throwable = JavApi.Throwable
  public typealias Math = JavApi.Math
  public typealias Iterable = JavApi.Iterable
}

/// This type alias provides the byte keyword with UInt8 as data type
public typealias byte = UInt8
/// This type alias provides the boolean keyword with Bool as data type
public typealias boolean = Bool
/// This type alias provides the long keyword with Int64 as data type
public typealias long = Int64
