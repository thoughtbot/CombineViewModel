import os.lock

@propertyWrapper
struct UnfairAtomic<Value> {
  private class Buffer: ManagedBuffer<os_unfair_lock, Value> {
    deinit {
      _ = withUnsafeMutablePointerToElements {
        $0.deinitialize(count: 1)
      }
    }
  }

  private let buffer: Buffer

  init(wrappedValue: Value) {
    self.buffer = Buffer.create(minimumCapacity: 1) { buffer in
      buffer.withUnsafeMutablePointerToElements { $0.initialize(to: wrappedValue) }
      return os_unfair_lock()
    } as! Buffer
  }

  var projectedValue: UnfairAtomic {
    self
  }

  var wrappedValue: Value {
    buffer.withUnsafeMutablePointers { lock, value in
      os_unfair_lock_lock(lock)
      defer { os_unfair_lock_unlock(lock) }
      return value.pointee
    }
  }

  func swap(_ newValue: Value) -> Value {
    buffer.withUnsafeMutablePointers { lock, value in
      os_unfair_lock_lock(lock)
      defer {
        value.pointee = newValue
        os_unfair_lock_unlock(lock)
      }
      return value.pointee
    }
  }
}
