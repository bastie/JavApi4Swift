/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public enum OperationType : IDL_unsigned_short, Sendable {
    case NODE_CLONED   = 1
    case NODE_IMPORTED = 2
    case NODE_DELETED  = 3
    case NODE_RENAMED  = 4
    case NODE_ADOPTED  = 5
  }
}
