/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

/// - SeeAlso: [SPEC](https://webidl.spec.whatwg.org/#idl-DOMException)
public enum DOMExceptionCode: IDL_unsigned_short, Sendable {
  case INDEX_SIZE_ERR = 1
  case DOMSTRING_SIZE_ERR = 2
  case HIERARCHY_REQUEST_ERR = 3
  case WRONG_DOCUMENT_ERR = 4
  case INVALID_CHARACTER_ERR = 5
  case NO_DATA_ALLOWED_ERR = 6
  case NO_MODIFICATION_ALLOWED_ERR = 7
  case NOT_FOUND_ERR = 8
  case NOT_SUPPORTED_ERR = 9
  case INUSE_ATTRIBUTE_ERR = 10
  case INVALID_STATE_ERR = 11
  case SYNTAX_ERR = 12
  case INVALID_MODIFICATION_ERR = 13
  case NAMESPACE_ERR = 14
  case INVALID_ACCESS_ERR = 15
  case VALIDATION_ERR = 16
  case TYPE_MISMATCH_ERR = 17
  case SECURITY_ERR = 18
  case NETWORK_ERR = 19
  case ABORT_ERR = 20
  case URL_MISMATCH_ERR = 21
  case QUOTA_EXCEEDED_ERR = 22
  case TIMEOUT_ERR = 23
  case INVALID_NODE_TYPE_ERR = 24
  case DATA_CLONE_ERR = 25
}
