# CombineViewModel

An implementation of the Model-View-ViewModel (MVVM) pattern using Combine.

- [Example](#example)
- [Contributing](#contributing)
- [About](#about)

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

// (1) Conform your view controller to the ViewModelObserver protocol.
final class CounterViewController: UIViewController, ViewModelObserver {
  @IBOutlet private var valueLabel: UILabel!

  // (2) Declare your view model using the `@ViewModel` property wrapper.
  @ViewModel private var counter: Counter

  // (3) Initialize your view model in init().
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.counter = Counter()
  }

  // (4) The `updateView()` method is automatically called on the main queue
  //     when the view model changes. It is always called after `viewDidLoad()`.
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

## Contributing

Have a useful reactive extension in your project?
Please consider contributing it back to the community!

For more details, see the [CONTRIBUTING][] document.
Thank you, [contributors][]!

  [CONTRIBUTING]: CONTRIBUTING.md
  [contributors]: https://github.com/thoughtbot/Bindings/graphs/contributors

## License

CombineViewModel is Copyright © 2019–20 thoughtbot, inc.
It is free software, and may be redistributed
under the terms specified in the [LICENSE][] file.

  [LICENSE]: /LICENSE

## About

![thoughtbot](http://presskit.thoughtbot.com/images/thoughtbot-logo-for-readmes.svg)

Bindings is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software!
See [our other projects][community]
or [hire us][hire] to help build your product.

  [community]: https://thoughtbot.com/community?utm_source=github
  [hire]: https://thoughtbot.com/hire-us?utm_source=github
