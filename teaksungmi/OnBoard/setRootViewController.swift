


import SwiftUI
import UIKit
import RealmSwift

let realm = try! Realm()

extension SceneDelegate {
    
    public func setRootViewController(_ scene: UIScene){
        if (!CheckFirst.isFirstTime()) && (!realm.isEmpty)  {
            print(realm.isEmpty)
            setRootViewController(scene, name: "Main",
                                identifier: "Main")
        }else {
            print(realm.isEmpty)
            setRootViewController(scene, name: "Login",
                                  identifier: "Login")
        }
    }
    
    public func setRootViewController(_ scene: UIScene, name: String, identifier: String) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let storyboard = UIStoryboard(name: name, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
            window.rootViewController = viewController
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
public class CheckFirst {
    static func isFirstTime() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isFirstTime") == nil {
            defaults.set("No", forKey:"isFirstTime")
            return true
        } else {
            return false
        }
    }
}
