import Combine

public protocol ViewModelObserver: AnyObject {
  var isReadyForUpdates: Bool { get }
  var subscriptions: Set<AnyCancellable> { get set }
  func updateView()
}

extension ViewModelObserver {
  public var isReadyForUpdates: Bool {
    true
  }
}

#if canImport(UIKit)
import UIKit

extension UIViewController {
  @objc open var isReadyForUpdates: Bool {
    isViewLoaded
  }
}
#endif
