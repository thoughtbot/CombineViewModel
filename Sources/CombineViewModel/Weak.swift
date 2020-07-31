final class Weak<Object: AnyObject> {
  weak var object: Object?

  init(_ object: Object) {
    self.object = object
  }
}
