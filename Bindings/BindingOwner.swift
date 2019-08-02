import Combine
import Foundation

private var bindingOwnerSubscriptionsKey: UInt8 = 0

public protocol BindingOwner: AnyObject, ReactiveExtensionProvider {
  associatedtype Subscriptions: RangeReplaceableCollection where Subscriptions.Element == AnyCancellable
  var subscriptions: Subscriptions { get set }
}

extension BindingOwner {
  public var subscriptions: [AnyCancellable] {
    get {
      if let object = objc_getAssociatedObject(self, &bindingOwnerSubscriptionsKey) {
        return (object as! Box<[AnyCancellable]>).value
      } else {
        return []
      }
    }
    set {
      if let object = objc_getAssociatedObject(self, &bindingOwnerSubscriptionsKey) {
        (object as! Box<[AnyCancellable]>).value = newValue
      } else {
        objc_setAssociatedObject(self, &bindingOwnerSubscriptionsKey, Box(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }
}

extension NSObject: BindingOwner {}
