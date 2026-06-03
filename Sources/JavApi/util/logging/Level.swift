/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {
  
  /// - Since: Java 1.4
  open class Level {
    
    nonisolated(unsafe) public static let OFF : Level = Level("OFF", Int.max)
    nonisolated(unsafe) public static let SEVERE : Level = Level("SEVERE", 1000)
    nonisolated(unsafe) public static let WARNING : Level = Level("WARNING", 900)
    nonisolated(unsafe) public static let INFO : Level = Level("INFO", 800)
    nonisolated(unsafe) public static let CONFIG : Level = Level("CONFIG", 700)
    nonisolated(unsafe) public static let FINE : Level = Level("FINE", 500)
    nonisolated(unsafe) public static let FINER : Level = Level("FINER", 400)
    nonisolated(unsafe) public static let FINEST : Level = Level("FINEST", 300)
    nonisolated(unsafe) public static let ALL : Level = Level("ALL", Int.min)
    
    private var resourceBundleName : String?
    private var name : String
    private var value: Int
    
    public init (_ theName : String, _ intValue: Int) {
      self.name = theName
      self.value = intValue
    }
    
    public convenience init (_ name: String, _ value: Int, _ resourceBundleName: String?) {
      if resourceBundleName != nil && !resourceBundleName!.isEmpty {
        fatalError("not implemented yet")
      }
      self.init (name, value)
    }
    
    open func getResourceBundleName() -> String? {
      return self.resourceBundleName
    }
    
    open func getName () -> String {
      return self.name
    }
    
    public func intValue() -> Int {
      return self.value
    }
    
    @MainActor public static func parse(_ name: String) throws -> Level {
      switch name {
      case "OFF": return .OFF
      case "SEVERE": return .SEVERE
      case "WARNING": return .WARNING
      case "INFO": return .INFO
      case "CONFIG": return .CONFIG
      case "FINE": return .FINE
      case "FINER": return .FINER
      case "FINEST": return .FINEST
      case "ALL": return .ALL
      default:
        if let intValue = Int(name) {
          switch intValue {
          case Int.max: return .OFF
          case Int.min: return .ALL
          case 1000: return .SEVERE
          case 900: return .WARNING
          case 800: return .INFO
          case 700: return .CONFIG
          case 500: return .FINE
          case 400: return .FINER
          case 300: return .FINEST
          default:
            throw IllegalArgumentException("\(name) is not a valid Level")
          }
        }
        throw IllegalArgumentException("\(name) is not a valid Level")
      }
    }
  }
  
}
