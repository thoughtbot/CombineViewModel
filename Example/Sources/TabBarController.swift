import UIKit

final class TabBarController: UITabBarController, UITabBarControllerDelegate {
  override func viewDidLoad() {
    super.viewDidLoad()

    delegate = self
    selectedIndex = UserDefaults.standard.integer(forKey: "selectedTab")
  }

  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    let index = tabBarController.viewControllers!.firstIndex(of: viewController)!
    UserDefaults.standard.set(index, forKey: "selectedTab")
  }
}
