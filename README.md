# CombineViewModel

An implementation of the Model-View-ViewModel (MVVM) pattern using Combine.

## Example

### Step 1: A view model is class that conforms to `ObservableObject`

```swift
// Counter.swift

import CombineViewModel
import Foundation

final class Counter: ObservableObject {
  @Published private(set) var value = 0

  var formattedValue: String {
    NumberFormatter.localizedString(
      for: NSNumber(value: value),
      number: .decimal
    )
  }

  func increment() {
    value += 1
  }

  func decrement() {
    value -= 1
  }
}
```

### Step 2: Observe a view model with the `@ViewModel` property wrapper

```swift
// CounterViewController.swift

import CombineViewModel
import UIKit

// (1) Conform to you view controller to the ViewModelObserver protocol.
//
final class CounterViewController: UIViewController, ViewModelObserver {
  @IBOutlet private var valueLabel: UILabel!

  // (2) Declare your view model using the `@ViewModel` property wrapper.
  //
  @ViewModel private var counter: Counter
  var subscriptions: Set<AnyCancellable> = []

  // (3) Initialize your view model in init().
  //
  required init?(coder: NSCoder) {
    self.counter = Counter()
  }

  // (4) The `updateView()` method is automatically called on the main queue
  //     when the view model changes. It is always called after `viewDidLoad()`.
  //
  func updateView() {
    valueLabel.text = counter.formattedValue
  }

  @IBAction func increment() {
    counter.increment()
  }

  @IBAction func decrement() {
    counter.decrement()
  }
}
```
