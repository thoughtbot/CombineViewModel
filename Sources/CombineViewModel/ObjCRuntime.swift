#if canImport(ObjectiveC)
import ObjectiveC.runtime
import Foundation

private let _UIViewController: AnyClass? = NSClassFromString("UIViewController")
private var _isHookedKey = UInt8(0)
private var _shouldPostKey = UInt8(0)

private typealias ViewDidLoadBlock = @convention(block) (Any) -> Void
private typealias ViewDidLoadFunction = @convention(c) (Any, Selector) -> Void

func combinevm_isHooked(_ object: Any) -> Bool {
  objc_getAssociatedObject(object, &_isHookedKey) as? Bool ?? false
}

private func combinevm_setIsHooked(_ object: Any, _ isHooked: Bool) {
  objc_setAssociatedObject(object, &_isHookedKey, isHooked, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

private func combinevm_shouldPost(_ object: Any) -> Bool {
  objc_getAssociatedObject(object, &_shouldPostKey) as? Bool ?? true
}

private func combinevm_setShouldPost(_ object: Any, _ shouldPost: Bool) {
  objc_setAssociatedObject(object, &_shouldPostKey, shouldPost, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

#if canImport(UIKit) && !os(watchOS)
import class UIKit.UIViewController

extension UIViewController {
  @nonobjc static let viewDidLoadNotification = Notification.Name("CombineViewModelViewDidLoad")

  @nonobjc func hookViewDidLoad() {
    guard !combinevm_isHooked(type(of: self)) else { return }

    var originalIMP: IMP!
    let `class`: Any
    let method: Method
    let selector = #selector(viewDidLoad)

    (method, `class`) = object_getInstanceMethod(self, name: selector)!

    let block: ViewDidLoadBlock = { `self` in
      let shouldPost = combinevm_shouldPost(self)
      let viewDidLoad = unsafeBitCast(originalIMP!, to: ViewDidLoadFunction.self)

      if shouldPost {
        combinevm_setShouldPost(self, false)
      }

      viewDidLoad(self, selector)

      if shouldPost {
        combinevm_setShouldPost(self, true)
        NotificationCenter.default.post(name: UIViewController.viewDidLoadNotification, object: self)
      }
    }

    originalIMP = method_setImplementation(method, imp_implementationWithBlock(block))

    combinevm_setIsHooked(`class`, true)
  }
}
#endif // canImport(UIKit) && !os(watchOS)

private func object_getInstanceMethod(_ object: Any, name: Selector) -> (method: Method, class: AnyClass)? {
  guard var hierarchy = ClassHierarchy(object: object)?.makeIterator() else { return nil }
  var stop = false

  while !stop, let `class` = hierarchy.next() {
    if `class` === _UIViewController {
      stop = true
    }

    guard let methods = MethodList(class: `class`) else { continue }

    if let method = methods.first(where: { method_getName($0) == name }) {
      return (method, `class`)
    }
  }

  return nil
}

private func object_isHooked(_ object: Any) -> Bool {
  guard let hierarchy = ClassHierarchy(object: object) else { return false }

  for `class` in hierarchy {
    if combinevm_isHooked(`class`) {
      return true
    }

    if `class` === _UIViewController {
      break
    }
  }

  return false
}
#endif
