//
//  AppDelegate.swift
//  XuChat
//
//  Created by Ercan on 1.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit
import CoreData
import FirebaseMessaging
import FirebaseCore
import Kingfisher


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var token : String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        FireStoreHelper.shared.fetchCurrentUser()
        
        if #available(iOS 10.0, *) {
            
          // For iOS 10 display notification (sent via APNS)
          //UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle

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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Geldi")
        completionHandler(.newData)
    }
    
    func createNotification(){
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Başlık"
        notificationContent.subtitle = "Alt Başlık"
        notificationContent.body = "Body Kısmı"
        notificationContent.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "fcm", content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "XuChat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
                
        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let data = response.notification.request.content.userInfo as! [String:Any]
        center.removeAllDeliveredNotifications()
        showViewControl(data: data)
        completionHandler()
    }
    
    func showViewControl(data : [String : Any]){
        
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chattingScene = storyboard.instantiateViewController(withIdentifier: "chattingScene") as! ChattingScene
        
        let imageURL = data["imageURL"] as! String
        chattingScene.userName = data["userName"] as? String
        chattingScene.userID = data["userID"] as? String
        chattingScene.resource = ImageResource(downloadURL: URL(string: imageURL)!, cacheKey: imageURL)
        
        print(imageURL)
        
        if  let tabBarController = rootViewController as? UITabBarController,
            let navController = tabBarController.selectedViewController as? UINavigationController {
            
            if navController.viewControllers.count > 1 {
                print("1 den fazla")
                navController.viewControllers.removeLast()
                navController.pushViewController(chattingScene, animated: true)
            }else{
                print("Else kısmı")
                navController.pushViewController(chattingScene, animated: true)
            }
        }
        
    }
    
}


extension AppDelegate : MessagingDelegate {
  // [START refresh_token]
    
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    print(fcmToken)
    token = fcmToken
  }

}

