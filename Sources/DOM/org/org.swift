/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */
/// The org namespace
///
/// - Copyright: Apple and Swift are registered trademarks of Apple and/or its affiliates. Oracle and Java are registered trademarks of Oracle and/or its affiliates. Copyright by W3C for IDL definitions.
/// Other names may be trademarks of their respective owners.
public enum org {}

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-boolean
public typealias IDL_boolean = Bool

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-octet
public typealias IDL_octet = UInt8

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-unsigned-short
public typealias IDL_short = Int16

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-unsigned-short
public typealias IDL_unsigned_short = UInt16

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-long
public typealias IDL_long = Int32

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-unsigned-long
public typealias IDL_unsigned_long = UInt32

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-long-long
public typealias IDL_long_long = Int64

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-unsigned-long-long
public typealias IDL_unsigned_long_long = UInt64

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-float
public typealias IDL_float = Float

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-unrestricted-float
public typealias IDL_unrestricted_float = Float

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-double
public typealias IDL_double = Double

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-unrestricted-double
public typealias IDL_unrestricted_double = Double

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-bigint
public typealias IDL_bigint = Int128 // FIXME: use real BigInt if implemented in JavApi

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-DOMString
public typealias IDL_DOMString = String

/// - SeeAlso: https://webidl.spec.whatwg.org/#idl-DOMString
public typealias IDL_nullable_DOMString = String?
