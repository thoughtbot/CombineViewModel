#if canImport(UIKit)
import CombineViewModelObjC
import ObjectiveC.runtime
import UIKit
import XCTest

final class HookedViewDidLoadTests: XCTestCase {
  func testItHooksOverriddenViewDidLoad() {
    class ViewController: UIViewController {
      override func viewDidLoad() {
        super.viewDidLoad()
      }
    }

    let object = ViewController()
    _combinevm_hook_viewDidLoad(object)
    let isHooked = objc_getAssociatedObject(ViewController.self, CombineViewModelIsHookedKey) as? Bool == true
    XCTAssertTrue(isHooked)
  }

  func testItHooksBaseClassViewDidLoad() {
    class Base: UIViewController {
      override func viewDidLoad() {
        super.viewDidLoad()
      }
    }

    class Sub: Base {}

    let object = Sub()
    _combinevm_hook_viewDidLoad(object)
    let isBaseHooked = objc_getAssociatedObject(Base.self, CombineViewModelIsHookedKey) as? Bool == true
    let isSubHooked = objc_getAssociatedObject(Sub.self, CombineViewModelIsHookedKey) as? Bool == true
    XCTAssertTrue(isBaseHooked)
    XCTAssertFalse(isSubHooked)
  }
}
#endif
