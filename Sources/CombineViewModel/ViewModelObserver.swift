import Combine

public protocol ViewModelObserver: AnyObject {
  var subscriptions: Set<AnyCancellable> { get set }
  func updateView()
}
