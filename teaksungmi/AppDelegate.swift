
import UIKit
import Firebase
import FirebaseMessaging
import GoogleMaps
import RealmSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        sleep(1)
        
        FirebaseApp.configure()
        
        // Google Map API
        GMSServices.provideAPIKey("AIzaSyDmH-Fl0lGalTRA1TxQUBJC19MXMnncnSs")  // 위에서 생성한 API Key를 YOUR_API_KEY 위치에 추가
        
        Messaging.messaging().delegate = self
          UNUserNotificationCenter.current().delegate = self
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
          UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
          application.registerForRemoteNotifications()
        let realm = try! Realm()
        let stampI = realm.objects(Stamp.self)
        try! realm.write{
            realm.delete(stampI)
        }
        return true
    }
    
    //파이어베이스 noti관리
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
      print("[Log] 파이어 베이스 토큰 :", deviceTokenString)

        // deviceTokenString , 291791A92D6CA36D58501F319FFA389F52503BC7490D725EDFF3A23BF3455083 토큰값
      Messaging.messaging().apnsToken = deviceToken
    }

          func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        
      }
      
      func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
      }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
      }
      


    // MARK: UISceneSession Lifecycle

    func applicationWillTerminate(_ application: UIApplication) {
        
        //나에게 노티 띄우기
        let content = UNMutableNotificationContent()
        
        content.title = "앱을 강제종료하셨군요!"
        content.body = "위치 정확도가 떨어질 수 있어요 앱을 터치하여 다시 켜주세요."

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound], completionHandler: {didAllow,Error in })
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats:false)
        let req = UNNotificationRequest(identifier: "terminate", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
        
        sleep(3)
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // 세로방향 고정
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
            return UIInterfaceOrientationMask.portrait
        }
    
    // 사일런트 푸시 처리 메소드
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Receive silent push>", userInfo)
        completionHandler(.newData)
    }}

