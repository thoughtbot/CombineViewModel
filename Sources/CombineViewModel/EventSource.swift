import Combine

public protocol EventSource: AnyObject, Cancellable {
  func signal()
}
