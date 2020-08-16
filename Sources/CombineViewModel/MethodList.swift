#if canImport(ObjectiveC)
import ObjectiveC.runtime

struct MethodList {
  private let buffer: UnsafeBufferPointer<Method>

  init?(class: AnyClass) {
    var count = UInt32(0)
    guard let list = class_copyMethodList(`class`, &count) else { return nil }
    self.buffer = UnsafeBufferPointer(start: list, count: Int(count))
  }
}

extension MethodList: RandomAccessCollection {
  var startIndex: Int {
    buffer.startIndex
  }

  var endIndex: Int {
    buffer.endIndex
  }

  subscript(position: Int) -> Method {
    buffer[position]
  }
}
#endif
