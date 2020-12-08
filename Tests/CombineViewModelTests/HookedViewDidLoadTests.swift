#if canImport(UIKit)
@testable import CombineViewModel
import ObjCTestSupport
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
    object.hookViewDidLoad()
    XCTAssertTrue(combinevm_isHooked(ViewController.self))
  }

  func testItHooksBaseClassViewDidLoad() {
    class Base: UIViewController {
      override func viewDidLoad() {
        super.viewDidLoad()
      }
    }

    class Sub: Base {}

    let object = Sub()
    object.hookViewDidLoad()
    XCTAssertTrue(combinevm_isHooked(Base.self), "Expected base class to be hooked")
    XCTAssertFalse(combinevm_isHooked(Sub.self), "Expected sub class not to be hooked")
  }

  func testViewDidLoadSelector() {
    let controller = TestObjCViewController()
    controller.hookViewDidLoad()

    _ = controller.view

    XCTAssertEqual(controller.viewDidLoadSelector, #selector(UIViewController.viewDidLoad))
  }

  func testRecursiveViewDidLoad() {
    class ViewModelObserver: UIViewController {
      override func viewDidLoad() {
        super.viewDidLoad()
      }
    }

    class Unrelated: UIViewController {}

    let observer = ViewModelObserver()
    observer.hookViewDidLoad()
    Unrelated().hookViewDidLoad()

    var notificationCount = 0

    let token = NotificationCenter.default.addObserver(forName: UIViewController.viewDidLoadNotification, object: observer, queue: nil) { _ in
      notificationCount += 1
    }
    defer { NotificationCenter.default.removeObserver(token) }

    _ = observer.view

    XCTAssertEqual(notificationCount, 1, "Expected recursively-hooked viewDidLoad() to fire only a single notification.")
  }
}
#endif
