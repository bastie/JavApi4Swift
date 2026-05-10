/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

open class EnumConstantNotPresentException<EnumType: RawRepresentable> : RuntimeException, @unchecked Sendable {
  
  private let _enumType: EnumType.Type
  private let _constantName: String
  
  public init(enumType: EnumType.Type, constantName: String) {
    self._enumType = enumType
    self._constantName = constantName
    super.init()
  }
  
  public func enumType() -> EnumType.Type {
    return _enumType
  }
  
  public func constantName() -> String {
    return _constantName
  }
}
