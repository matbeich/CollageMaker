//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Crashlytics
import Fabric
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    let navigator = AppNavigator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigator.rootViewController
        window?.makeKeyAndVisible()

        return true
    }
}
