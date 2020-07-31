import CombineViewModel
import XCTest

final class DispatchQueueEventSourceSchedulerTests: XCTestCase {
  var source: DispatchQueue.EventSource!
  lazy var sourceFired: XCTestExpectation! = expectation(description: "event source fired")

  override func tearDown() {
    source = nil
    super.tearDown()
  }

  func testItCoalescesEvents() {
    var eventCount: Int?
    source = DispatchQueue.main.scheduleEventSource { source in
      eventCount = source.eventCount
      self.sourceFired.fulfill()
    }

    source.signal()
    source.signal()
    wait(for: [sourceFired], timeout: 0.1)

    XCTAssertEqual(eventCount, 2)
  }

  func testItStopsDeliveringEventsWhenCancelled() {
    var fireCount = 0

    source = DispatchQueue.main.scheduleEventSource { _ in
      fireCount += 1
    }

    source.signal()
    CFRunLoopRunInMode(.defaultMode, 0, true)

    source.signal()
    source.cancel()
    CFRunLoopRunInMode(.defaultMode, 0, true)

    XCTAssertEqual(fireCount, 1)
  }

  func testItStopsDeliveringEventsDeinitialized() {
    var fireCount = 0

    source = DispatchQueue.main.scheduleEventSource { _ in
      fireCount += 1
    }

    source.signal()
    CFRunLoopRunInMode(.defaultMode, 0, true)

    source.signal()
    source = nil
    CFRunLoopRunInMode(.defaultMode, 0, true)

    XCTAssertEqual(fireCount, 1)
  }
}
