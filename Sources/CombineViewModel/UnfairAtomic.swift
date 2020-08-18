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

  init(_ wrappedValue: Value) {
    self.init(wrappedValue: wrappedValue)
  }

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
    get {
      buffer.withUnsafeMutablePointers { lock, value in
        os_unfair_lock_lock(lock)
        defer { os_unfair_lock_unlock(lock) }
        return value.pointee
      }
    }
    nonmutating set {
      buffer.withUnsafeMutablePointers { lock, value in
        os_unfair_lock_lock(lock)
        value.pointee = newValue
        os_unfair_lock_unlock(lock)
      }
    }
    nonmutating _modify {
      var temporaryValue = buffer.withUnsafeMutablePointers { lock, value -> Value in
        os_unfair_lock_lock(lock)
        return value.move()
      }
      defer {
        buffer.withUnsafeMutablePointers { lock, value in
          value.initialize(to: temporaryValue)
          os_unfair_lock_unlock(lock)
        }
      }
      yield &temporaryValue
    }
  }

  func withLock<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
    try body(&wrappedValue)
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
