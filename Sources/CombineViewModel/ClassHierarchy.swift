#if canImport(ObjectiveC)
import ObjectiveC.runtime

struct ClassHierarchy: Sequence {
  struct Iterator: IteratorProtocol {
    var `class`: AnyClass?

    init(class: AnyClass) {
      self.class = `class`
    }

    mutating func next() -> AnyClass? {
      guard let next = `class` else { return nil }
      `class` = class_getSuperclass(next)
      return next
    }
  }

  var `class`: AnyClass

  func makeIterator() -> Iterator {
    Iterator(class: `class`)
  }
}

extension ClassHierarchy {
  init?(object: Any) {
    guard let `class` = object_getClass(object) else { return nil }
    self.init(class: `class`)
  }
}
#endif
