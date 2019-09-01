import Combine
import Foundation

private var bindingOwnerSubscriptionsKey: UInt8 = 0

public protocol BindingOwner: AnyObject, ReactiveExtensionProvider {
  associatedtype Subscriptions: Collection & ExpressibleByArrayLiteral = [AnyCancellable]
    where Subscriptions.Element == AnyCancellable

  var subscriptions: Subscriptions { get set }
  func store(_ subcription: AnyCancellable)
}

extension NSObject: BindingOwner {}

extension BindingOwner where Subscriptions: RangeReplaceableCollection {
  public var subscriptions: Subscriptions {
    get { _subscriptions }
    set { _subscriptions = newValue }
  }

  public func store(_ subscription: AnyCancellable) {
    subscription.store(in: &subscriptions)
  }
}

extension BindingOwner where Subscriptions == Set<AnyCancellable> {
  public var subscriptions: Subscriptions {
    get { _subscriptions }
    set { _subscriptions = newValue }
  }

  public func store(_ subscription: AnyCancellable) {
    subscription.store(in: &subscriptions)
  }
}

private extension BindingOwner {
  var _subscriptions: Subscriptions {
    get {
      if let object = objc_getAssociatedObject(self, &bindingOwnerSubscriptionsKey) {
        return (object as! Box<Subscriptions>).value
      } else {
        return []
      }
    }
    set {
      if let object = objc_getAssociatedObject(self, &bindingOwnerSubscriptionsKey) {
        (object as! Box<Subscriptions>).value = newValue
      } else {
        objc_setAssociatedObject(self, &bindingOwnerSubscriptionsKey, Box(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }
}
