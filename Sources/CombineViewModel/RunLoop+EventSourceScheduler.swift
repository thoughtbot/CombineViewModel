import Combine
import Foundation

extension RunLoop: EventSourceScheduler {
  public struct EventSourceOptions {
    public var mode: RunLoop.Mode

    public init(mode: RunLoop.Mode) {
      self.mode = mode
    }
  }

  public typealias EventSourceType = EventSource

  public final class EventSource {
    private typealias Ref = Weak<EventSource>

    private static let eventHandler: @convention(c) (UnsafeMutableRawPointer?) -> Void = { context in
      Unmanaged<Ref>.fromOpaque(context!).takeUnretainedValue().object?.handleEvent()
    }

    private static let cancelHandler: @convention(c) (UnsafeMutableRawPointer?, CFRunLoop?, CFRunLoopMode?) -> Void = { context, _, _ in
      Unmanaged<Ref>.fromOpaque(context!).release()
    }

    private let eventHandler: (EventSource) -> Void
    private let mode: CFRunLoopMode
    private let runLoop: CFRunLoop
    private var source: CFRunLoopSource!
    @UnfairAtomic private var isCancelled = false

    init(runLoop: RunLoop, mode: RunLoop.Mode, eventHandler: @escaping (EventSource) -> Void) {
      self.eventHandler = eventHandler
      self.mode = CFRunLoopMode(mode.rawValue as CFString)
      self.runLoop = runLoop.getCFRunLoop()

      let ref = Weak(self)
      var context = CFRunLoopSourceContext()
      context.info = Unmanaged.passRetained(ref).toOpaque()
      context.perform = EventSource.eventHandler
      context.cancel = EventSource.cancelHandler
      self.source = CFRunLoopSourceCreate(nil, 0, &context)!
    }

    deinit {
      cancel()
    }

    func handleEvent() {
      eventHandler(self)
    }

    func schedule() {
      CFRunLoopAddSource(runLoop, source, mode)
    }
  }

  public func scheduleEventSource(options: EventSourceOptions? = nil, eventHandler: @escaping (EventSource) -> Void) -> EventSource {
    let mode = options?.mode ?? .default
    let source = EventSource(runLoop: self, mode: mode, eventHandler: eventHandler)
    source.schedule()
    return source
  }
}

extension RunLoop.EventSource: EventSource {
  public func signal() {
    guard !isCancelled else { return }
    CFRunLoopSourceSignal(source)
    CFRunLoopWakeUp(runLoop)
  }

  public func cancel() {
    let wasCancelled = $isCancelled.swap(true)
    if !wasCancelled {
      CFRunLoopRemoveSource(runLoop, source, mode)
    }
  }
}
