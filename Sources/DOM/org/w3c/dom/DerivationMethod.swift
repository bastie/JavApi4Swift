/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  public enum DerivationMethod: IDL_unsigned_long, Sendable {
    case DERIVATION_RESTRICTION    = 0x00000001
    case DERIVATION_EXTENSION      = 0x00000002
    case DERIVATION_UNION          = 0x00000004
    case DERIVATION_LIST           = 0x00000008
  }
}
/*
 // Introduced in DOM Level 3:
 interface TypeInfo {
 readonly attribute DOMString       typeName;
 readonly attribute DOMString       typeNamespace;
 
 // DerivationMethods
 const unsigned long       DERIVATION_RESTRICTION         = 0x00000001;
 const unsigned long       DERIVATION_EXTENSION           = 0x00000002;
 const unsigned long       DERIVATION_UNION               = 0x00000004;
 const unsigned long       DERIVATION_LIST                = 0x00000008;
 
 boolean            isDerivedFrom(in DOMString typeNamespaceArg,
 in DOMString typeNameArg,
 in unsigned long derivationMethod);
 };
 */

