//
//  SceneDelegate.swift
//  XuChat
//
//  Created by Ercan on 1.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let tabBarVC = storyBoard.instantiateViewController(withIdentifier: "mainTabBar") as! MainTabBar
        let signIn = storyBoard.instantiateViewController(withIdentifier: "signIn") as! SignInScene

        if Auth.auth().currentUser != nil {
            window?.rootViewController = tabBarVC
        }else{
            window?.rootViewController = signIn
        }
        setUserStatus(isOnline: true)
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        
        setUserStatus(isOnline: false)

        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        setUserStatus(isOnline: true)

    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        setUserStatus(isOnline: false)

        
    }
    
    func setUserStatus(isOnline : Bool){
        
        if let _ = Auth.auth().currentUser {
            FireStoreHelper.shared.setUserStatus(isOnline: isOnline, permission: true, time: Timestamp(date: Date()))
        }
    }


}

