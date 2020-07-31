import Combine
import Dispatch

extension DispatchQueue: EventSourceScheduler {
  public typealias EventSourceOptions = Never
  public typealias EventSourceType = EventSource

  public final class EventSource {
    @UnfairAtomic private var isCancelled = false
    private let source: DispatchSourceUserDataAdd

    init(queue: DispatchQueue, eventHandler: @escaping (DispatchQueue.EventSource) -> Void) {
      self.source = DispatchSource.makeUserDataAddSource(queue: queue)
      source.setEventHandler { [weak self] in
        guard let self = self else { return }
        eventHandler(self)
      }
    }

    deinit {
      cancel()
    }

    public var eventCount: Int {
      Int(source.data)
    }

    func resume() {
      source.resume()
    }
  }

  public func scheduleEventSource(options: EventSourceOptions? = nil, eventHandler: @escaping (EventSource) -> Void) -> EventSource {
    let source = EventSource(queue: self, eventHandler: eventHandler)
    source.resume()
    return source
  }
}

extension DispatchQueue.EventSource: EventSource {
  public func signal() {
    if !isCancelled {
      source.add(data: 1)
    }
  }

  public func cancel() {
    let wasCancelled = $isCancelled.swap(true)
    if !wasCancelled {
      source.cancel()
    }
  }
}
