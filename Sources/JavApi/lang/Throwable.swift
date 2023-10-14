/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
// TODO: Implementation of Throwable is a "incubation"
/// Mapping of Java exception handling
public enum Throwable : Error {
  case Exception (_ message : String = "Exception")
  case CloneNotSupportedException (_ message : String = "CloneNotSupportedException")
  case IllegalArgumentException (_ message : String = "IllegalArgumentException")
  case NullPointerException (_ message : String = "NullPointerExeception")
  case UnsupportedEncodingException (_ message : String = "UnsupportedEncodingException")
}

