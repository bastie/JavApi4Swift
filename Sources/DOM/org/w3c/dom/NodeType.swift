/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

public enum NodeType: IDL_unsigned_short, Sendable {
  case ELEMENT_NODE                   = 1
  case ATTRIBUTE_NODE                 = 2
  case TEXT_NODE                      = 3
  case CDATA_SECTION_NODE             = 4
  case ENTITY_REFERENCE_NODE          = 5
  case ENTITY_NODE                    = 6
  case PROCESSING_INSTRUCTION_NODE    = 7
  case COMMENT_NODE                   = 8
  case DOCUMENT_NODE                  = 9
  case DOCUMENT_TYPE_NODE             = 10
  case DOCUMENT_FRAGMENT_NODE         = 11
  case NOTATION_NODE                  = 12
}
