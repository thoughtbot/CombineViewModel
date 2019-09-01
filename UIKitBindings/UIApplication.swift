#if canImport(UIKit)
import Bindings
import Combine
import UIKit

extension Reactive where Base: UIApplication {
  public static var didBecomeActiveNotification: Publishers.Map<NotificationCenter.Publisher, Void> {
    NotificationCenter.default.publisher(for: Base.didBecomeActiveNotification).map { _ in }
  }
}
#endif
