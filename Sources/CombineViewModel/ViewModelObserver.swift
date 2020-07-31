import Combine

public protocol ViewModelObserver: AnyObject {
  var isViewLoaded: Bool { get }
  var subscriptions: Set<AnyCancellable> { get set }
  func updateView()
}

extension ViewModelObserver {
  public var isViewLoaded: Bool {
    true
  }
}
