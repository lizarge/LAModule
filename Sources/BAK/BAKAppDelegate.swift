
import UIKit
import FacebookCore

class BAKAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.launchOptions = launchOptions
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = BAK.shared.hostView
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(
           _ app: UIApplication,
           open url: URL,
           options: [UIApplication.OpenURLOptionsKey : Any] = [:]
       ) -> Bool {
           ApplicationDelegate.shared.application(
               app,
               open: url,
               sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
               annotation: options[UIApplication.OpenURLOptionsKey.annotation]
           )
       }  
    
}
