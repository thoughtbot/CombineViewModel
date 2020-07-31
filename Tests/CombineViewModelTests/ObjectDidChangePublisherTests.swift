import Combine
import CombineViewModel
import XCTest

private final class ViewModel: ObservableObject {
  @Published var counter = 0
}

final class ObjectDidChangePublisherTests: XCTestCase {
  private var subscriptions: Set<AnyCancellable> = []

  override func tearDown() {
    subscriptions.removeAll()
    super.tearDown()
  }

  func testObjectDidChangeOnRunLoop() {
    let viewModel = ViewModel()

    var counterObservations: [Int] = []
    viewModel.observe(on: RunLoop.main)
      .sink { counterObservations.append($0.counter) }
      .store(in: &subscriptions)

    XCTAssertEqual(counterObservations, [0])
    for _ in 1...10 {
      viewModel.counter += 1
    }
    CFRunLoopRunInMode(.defaultMode, 0, false)
    XCTAssertEqual(counterObservations, [0, 10])
  }
}
