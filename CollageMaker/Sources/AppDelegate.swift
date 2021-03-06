//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Crashlytics
import Fabric
import Firebase
import UIKit
import Utils

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if Environment.isTestEnvironment { return true }

        Fabric.with([Crashlytics.self])
        FirebaseApp.configure()

        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigator.rootViewController
        window?.makeKeyAndVisible()

        return true
    }

    private let navigator = AppNavigator()
}
