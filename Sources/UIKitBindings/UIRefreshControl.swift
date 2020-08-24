#if canImport(UIKit) && !os(watchOS)
import Bindings
import UIKit

@available(tvOS, unavailable)
extension Reactive where Base: UIRefreshControl {
  public var endRefreshing: BindingSink<Base, ()> {
    BindingSink(owner: base) { $0.endRefreshing() }
  }
}
#endif
