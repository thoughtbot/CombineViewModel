# CombineViewModel

An implementation of the Model-View-ViewModel (MVVM) pattern using Combine.

- [Introduction](#introduction)
- [Installation](#installation)
- [Bindings](#bindings)
- [Contributing](#contributing)
- [About](#about)

## Introduction

CombineViewModel’s primary goal is to make view updates as easy in UIKit and
AppKit as they are in SwiftUI.

In SwiftUI, you write model and view-model classes that conform to Combine’s
[`ObservableObject`][ObservableObject] protocol. SwiftUI:

1. Observes each model’s `objectWillChange` publisher via the
   [`@ObservedObject`][ObservedObject] property wrapper, and;
2. Automatically rerenders the appropriate portion of the view hierarchy.

The problem with `objectWillChange` _outside_ of SwiftUI is that there's no
built-in way of achieving (2) — being notified that an object _will_ change is
not the same as knowing that it _did_ change and it’s time to update the view.

  [ObservableObject]: https://developer.apple.com/documentation/combine/observableobject
  [ObservedObject]: https://developer.apple.com/documentation/swiftui/observedobject

### `ObjectDidChangePublisher`

Consider the following sketch of a view model for displaying a user’s social
networking profile:

```swift
// ProfileViewModel.swift

import CombineViewModel
import UIKit

class ProfileViewModel: ObservableObject {
  @Published var profileImage: UIImage?
  @Published var topPosts: [Post]

  func refresh() {
    // Request updated profile info from the server.
  }
}
```

With CombineViewModel, you can subscribe to _did change_ notifications using
the `observe(on:)` operator:

```swift
let profile = ProfileViewModel()

profileSubscription = profile.observe(on: DispatchQueue.main).sink { profile in
  // Called on the main queue when either (or both) of `profileImage`
  // or `topPosts` have changed.
}

profile.refresh()
```

### Automatic view updates

Building on `ObjectDidChangePublisher` is the `ViewModelObserver` protocol and
`@ViewModel` property wrapper. Instead of manually managing the
`ObjectDidChangePublisher` subscription like above, we can have it managed
automatically:

```swift
// ProfileViewController.swift

import CombineViewModel
import UIKit

// 1️⃣ Conform your view controller to the ViewModelObserver protocol.
class ProfileViewController: UITableViewController, ViewModelObserver {
  enum Section: Int {
    case topPosts
  }

  @IBOutlet private var profileImageView: UIImageView!
  private var dataSource: UITableViewDiffableDataSource<Section, Post>!

  // 2️⃣ Declare your view model using the `@ViewModel` property wrapper.
  @ViewModel private var profile: ProfileViewModel

  // 3️⃣ Initialize your view model in init().
  required init?(profile: ProfileViewModel, coder: NSCoder) {
    super.init(coder: coder)
    self.profile = profile
  }

  // 4️⃣ The `updateView()` method is automatically called on the main queue
  //     when the view model changes. It is always called after `viewDidLoad()`.
  func updateView() {
    profileImageView.image = profile.profileImage

    var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
    snapshot.appendSections([.topPosts])
    snapshot.appendItems(profile.topPosts)
    dataSource.apply(snapshot)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    profile.refresh()
  }
}
```

### Further reading

In the [Example](/Example) directory you’ll find a complete iOS sample
application that demonstrates how to integrate CombineViewModel into your
application.

## Installation

CombineViewModel is distributed via Swift Package Manager. To add it to your
Xcode project, navigate to File > Add Package Dependency…, paste in the
repository URL, and follow the prompts.

<img alt="Screen capture of Xcode on macOS Big Sur, with the Add Package Dependency menu item highlighted" width="945" src="/Documentation/Images/add-package-dependency.png">

## Bindings

CombineViewModel also provides the complementary [`Bindings`](/Sources/Bindings)
module. It provides two operators — `<~`, the **input binding operator**, and
`~>`, the **output binding operator** — along with various types and protocols
that support it. Note that the concept of a "binding" provided by the Bindings
module is different to [SwiftUI's `Binding` type][Binding].

  [Binding]: https://developer.apple.com/documentation/swiftui/binding

Platform-specific binding helpers are also provided:

- [UIKitBindings](/Sources/UIKitBindings)

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

CombineViewModel is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software!
See [our other projects][community]
or [hire us][hire] to help build your product.

  [community]: https://thoughtbot.com/community?utm_source=github
  [hire]: https://thoughtbot.com/hire-us?utm_source=github
