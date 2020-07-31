#if canImport(UIKit)
import UIKit

final class ViewDidLoadObserver {
  private static let callback: CFRunLoopObserverCallBack = { observer, _, context in
    let ref = Unmanaged<ViewDidLoadObserver>.fromOpaque(context!)
    if ref.takeUnretainedValue().handleCallback() {
      ref.release()
    }
  }

  let onViewDidLoad: () -> Void
  let viewController: UIViewController

  private var mode: CFRunLoopMode!
  private var observer: CFRunLoopObserver!

  init(viewController: UIViewController, onViewDidLoad: @escaping () -> Void) {
    self.onViewDidLoad = onViewDidLoad
    self.viewController = viewController
  }

  func schedule(forMode mode: RunLoop.Mode, in runLoop: RunLoop) {
    var context = CFRunLoopObserverContext()
    context.info = Unmanaged.passRetained(self).toOpaque()
    self.mode = CFRunLoopMode(mode.rawValue as CFString)
    observer = CFRunLoopObserverCreate(nil, CFRunLoopActivity.allActivities.rawValue, true, 0, ViewDidLoadObserver.callback, &context)
    CFRunLoopAddObserver(runLoop.getCFRunLoop(), observer, self.mode)
  }

  private func handleCallback() -> Bool {
    guard viewController.isViewLoaded else { return false }
    onViewDidLoad()
    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, mode)
    return true
  }
}
#endif
