#if canImport(UIKit)
import Combine
import CombineViewModelObjC
import UIKit

extension UIViewController {
  var viewDidLoadPublisher: AnyPublisher<UIView, Never> {
    if let view = viewIfLoaded {
      return Just(view).eraseToAnyPublisher()
    } else {
      return NotificationCenter.default
        .publisher(for: UIViewController.viewDidLoadNotification, object: self)
        .first()
        .map { ($0.object as! UIViewController).view }
        .eraseToAnyPublisher()
    }
  }
}
#endif
