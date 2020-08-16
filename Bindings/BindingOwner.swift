import Combine
import Foundation

private var bindingOwnerSubscriptionsKey: UInt8 = 0

public protocol BindingOwner: AnyObject, ReactiveExtensionProvider {
  associatedtype Subscriptions: Collection & ExpressibleByArrayLiteral = Set<AnyCancellable>
    where Subscriptions.Element == AnyCancellable

  var subscriptions: Subscriptions { get set }
  func store(_ subcription: AnyCancellable)
}

extension NSObject: BindingOwner {}

extension BindingOwner where Subscriptions: RangeReplaceableCollection {
  @inlinable
  public var subscriptions: Subscriptions {
    _read { yield _subscriptions }
    set { _subscriptions = newValue }
    _modify { yield &_subscriptions }
  }

  @inlinable
  public func store(_ subscription: AnyCancellable) {
    subscription.store(in: &subscriptions)
  }
}

extension BindingOwner where Subscriptions == Set<AnyCancellable> {
  @inlinable
  public var subscriptions: Subscriptions {
    _read { yield _subscriptions }
    set { _subscriptions = newValue }
    _modify { yield &_subscriptions }
  }

  @inlinable
  public func store(_ subscription: AnyCancellable) {
    subscription.store(in: &subscriptions)
  }
}

extension BindingOwner {
  @usableFromInline
  var _subscriptions: Subscriptions {
    _read {
      yield _getBox().value
    }
    set {
      _getBox().value = newValue
    }
    _modify {
      yield &_getBox().value
    }
  }

  @usableFromInline
  func _getBox() -> Box<Subscriptions> {
    let box: Box<Subscriptions>
    if let object = objc_getAssociatedObject(self, &bindingOwnerSubscriptionsKey) {
      box = object as! Box<Subscriptions>
    } else {
      box = Box([])
      objc_setAssociatedObject(self, &bindingOwnerSubscriptionsKey, box, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    return box
  }
}
