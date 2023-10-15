/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.nio {
  /// The standard open options for working with paths
  public enum StandardOpenOption : OpenOption {
    case APPEND
    case CREATE
    case CREATE_NEW
    case DELETE_ON_CLOSE
    case DSYNC
    case READ
    case SPARSE
    case SYNC
    case TRANCATE_EXISTING
    case WRITE
  }
}
