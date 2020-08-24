@testable import CombineViewModel
import XCTest

private final class TestViewModel: ObservableObject {
  @Published var counter = 0
}

private final class Controller: ViewModelObserver {
  var observations: [Int] = []
  @ViewModel var viewModel: TestViewModel

  init() {
    self.viewModel = TestViewModel()
  }

  func updateView() {
    observations.append(viewModel.counter)
  }
}

final class ViewModelTests: XCTestCase {
  func testViewModel() {
    let controller = Controller()
    XCTAssertEqual(controller.observations, [0])
    for _ in 1...5 {
      controller.viewModel.counter += 1
    }
    CFRunLoopRunInMode(.defaultMode, 0, true)
    XCTAssertEqual(controller.observations, [0, 5])
  }
}

#if canImport(UIKit)
import UIKit

private final class TestViewController: UIViewController, ViewModelObserver {
  @ViewModel var viewModel: TestViewModel
  var observations: [Int] = []

  init() {
    super.init(nibName: nil, bundle: nil)
    self.viewModel = TestViewModel()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateView() {
    observations.append(viewModel.counter)
  }
}

extension ViewModelTests {
  func testViewModelObservedOnViewDidLoad() {
    let controller = TestViewController()
    XCTAssertFalse(controller.isViewLoaded)
    XCTAssertEqual(controller.observations, [])

    DispatchQueue.main.async {
      _ = controller.view
    }
    CFRunLoopRunInMode(.defaultMode, 0, true)
    XCTAssertEqual(controller.observations, [0])
  }
}
#endif
