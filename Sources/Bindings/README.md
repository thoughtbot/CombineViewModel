# Bindings

Unidirectional binding operators and reactive extensions for Cocoa
classes.

## The operators

*Bindings* provides two operators: `<~`, the **input binding operator**, and
`~>`, the **output binding operator**.

### Input bindings update the state of your UI

```swift
import Bindings
import UIKitBindings

nameLabel.reactive.text <~ viewModel.fullName
```

### Output bindings respond to changes

```swift
nameField.reactive.edited ~> viewModel.setName
UIApplication.reactive.didBecomeActiveNotification ~> viewModel.refresh
```

## Common bindings for system classes

In addition to the core operator definitions, *Bindings* also provides
conveniences for using bindings with many system classes. Take a look at the
following modules to see what's provided (and consider
[contributing][CONTRIBUTING]!):

- [`UIKitBindings`][uikit] for apps using UIKit (iOS, iPadOS, Catalyst and more)
- More to come...

  [uikit]: /Sources/UIKitBindings

## Reactive extensions

It's convenient to group reactive extensions into their own namespace,
especially when extending types you don't own with reactive APIs.

Use the `ReactiveExtensionProvider` protocol to define the `.reactive` property
on your types:

```swift
extension MyViewModel: ReactiveExtensionProvider {}
```

Then add reactive extensions via the `Reactive` type:

```swift
extension UserDefaults {
  var username: String? {
    get { string(forKey: "username") }
    set { set(newValue, forKey: "username") }
  }
}

extension Reactive where Base: UserDefaults {
  var username: NSObject.KeyValueObservingPublisher<Base, String?> {
    base.publisher(for: \.username)
  }
}

UserDefaults.standard.reactive.username.sink { username in
  print("New username: \(username)")
}
```

## Bindings last for the lifetime of their owner

In Combine, the `AnyCancellable` class controls the lifetime of a subscription.
Subscriptions can be automatically cancelled by using the `store(in:)` method:

```swift
import UIKit

class MyViewController: UIViewController {
  @IBOutlet private var usernameLabel: UILabel!
  private var subscriptions: [AnyCancellable] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    UserDefaults.standard.reactive.username
      .sink { [usernameLabel] in usernameLabel?.text = $0 }
      .store(in: &subscriptions)
  }
}
```

_Bindings_ encapsulates this pattern with the `BindingOwner` protocol, which
automatically defines a `subscriptions` collection on all conforming classes.
The `BindingSink` subscriber then automatically disposes of the binding
subscription when its `owner` goes out of scope:

```swift
extension Reactive where Base: UILabel {
  var text: BindingSink<Base, String?> {
    BindingSink(owner: base) { label, newValue in
      label.text = newValue
    }
  }
}

// automatically cancelled when `usernameLabel` goes out of scope
usernameLabel.reactive.text <~ UserDefaults.standard.reactive.username
```
