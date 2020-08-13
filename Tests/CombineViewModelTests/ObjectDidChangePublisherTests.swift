import Combine
import CombineViewModel
import XCTest

private final class ViewModel: ObservableObject {
  @Published var counter = 0
}

private final class CustomPublisherViewModel: ObservableObject {
  let objectWillChange = PassthroughSubject<Void, Never>()

  func finish() {
    objectWillChange.send(completion: .finished)
  }
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

  func testObjectWillChangeCompletion() {
    let finished = expectation(description: "ObjectDidChangePublisher received finished")
    let viewModel = CustomPublisherViewModel()

    let subscription = viewModel.observe(on: DispatchQueue.main)
      .handleEvents(
        receiveCompletion: { _ in finished.fulfill() },
        receiveCancel: { XCTFail("Received cancel after completion") }
      )
      .sink { _ in }
    viewModel.finish()

    wait(for: [finished], timeout: 0.001)
    subscription.cancel()
  }
}
