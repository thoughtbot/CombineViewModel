import Combine
import os.log

extension Publisher {
  func logError(_ message: String, dso: UnsafeRawPointer = #dsohandle) -> Publishers.Catch<Self, Empty<Output, Never>> {
    self.catch { error in
      os_log(.error, dso: dso, "%@: %@", message, "\(error)")
      return Empty()
    }
  }
}
