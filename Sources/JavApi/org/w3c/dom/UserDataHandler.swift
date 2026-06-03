/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  public protocol UserDataHandler {
    func handle(_ operation : OperationType,_ key : IDL_DOMString,_ data : DOMUserData,_ src : Node?,_ dst : Node?);    
  }
}
