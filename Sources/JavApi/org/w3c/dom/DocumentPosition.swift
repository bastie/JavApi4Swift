/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */
extension org.w3c.dom {
  public enum DocumentPosition: IDL_unsigned_short, Sendable {
    case DOCUMENT_POSITION_DISCONNECTED            = 0x01
    case DOCUMENT_POSITION_PRECEDING               = 0x02
    case DOCUMENT_POSITION_FOLLOWING               = 0x04
    case DOCUMENT_POSITION_CONTAINS                = 0x08
    case DOCUMENT_POSITION_CONTAINED_BY            = 0x10
    case DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC = 0x20
  }
}
