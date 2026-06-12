/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java {
  /// The Java base class implementation
  public enum lang{}
}

// types to place in default namespace like Java
extension java.lang {
  public typealias Array = Swift.Array
  public typealias ArrayIndexOutOfBoundsException = JavApi.ArrayIndexOutOfBoundsException
  public typealias Cloneable = JavApi.Cloneable
  public typealias Comparable = JavApi.ComparableJ
  public typealias Compiler = JavApi.Compiler
  public typealias Exception = JavApi.Exception
  public typealias Error = JavApi.JError
  public typealias Float = Swift.Float
  public typealias Iterable = JavApi.Iterable
  public typealias IllegalArgumentException = JavApi.IllegalArgumentException
  public typealias IllegalStateException = JavApi.IllegalStateException
  public typealias IllegalThreadStateException = JavApi.IllegalThreadStateException
  public typealias IndexOutOfBoundsException = JavApi.IndexOutOfBoundsException
  public typealias IO = JavApi.IO
  public typealias Math = JavApi.Math
  public typealias Number = JavApi.Number
  public typealias Runnable = JavApi.Runnable
  public typealias RuntimeException = JavApi.RuntimeException
  public typealias System = JavApi.System
  public typealias String = Swift.String
  public typealias StringBuilder = JavApi.StringBuilder
  public typealias StringBuffer = JavApi.StringBuffer
  public typealias ThreadGroup = JavApi.ThreadGroup
  public typealias Throwable = JavApi.Throwable
  public typealias UnsupportedOperationException = JavApi.UnsupportedOperationException
  /* because SecurityManager is deprecated no typealias are provided
  public typealias SecurityManager = JavApi.SecurityManager
   */
}

/// This type alias provides the byte keyword with UInt8 as data type
public typealias byte = UInt8
/// This type alias provides the boolean keyword with Bool as data type
public typealias boolean = Bool
/// This type alias provides the long keyword with Int64 as data type
public typealias long = Int64
/// This type alias provides the float keyword with Float as data type
public typealias float = Float
