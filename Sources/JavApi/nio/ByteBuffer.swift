extension java.nio {
  
  public typealias ByteBuffer = JavApi.ByteBuffer
    
}

public protocol ByteBuffer {
  associatedtype ByteBuffer: java.nio.ByteBuffer

  var content : [UInt8]  { get set }

}

extension ByteBuffer {
  
  public func array () throws -> [UInt8] {
    return self.content
  }
  
}
