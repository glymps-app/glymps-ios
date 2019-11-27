//
//  AppDelegate.swift
//  GlympsApp
//
//  Created by James B Morris on 5/20/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications
import SmaatoSDKCore
import SmaatoSDKBanner
import SmaatoSDKInterstitial
import Purchases

// entire application config for Glymps iOS
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // remove notifications already delivered
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // initialize RevenueCat iOS SDK
//        Purchases.debugLogsEnabled = true
//        Purchases.configure(withAPIKey: "YgURteRoOLoOhJgOlUNNGDettfjWLqLn", appUserID: nil)
//        
        // initialize Smaato iOS SDK
        guard let config = SMAConfiguration(publisherId: "0") else {
                fatalError("SDK config is nil!")
        }
        config.httpsOnly = true // allow HTTPS traffic only
        config.logLevel = .error // log errors only
        SmaatoSDK.initSDK(withConfig: config)
        
        // Override point for customization after application launch, initialize Firebase iOS SDK
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // do stuff if push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("APN recieved")
        // print(userInfo)
        
        let state = application.applicationState
        switch state {
            
        case .inactive:
            print("Inactive")
            
        case .background:
            print("Background")
            // update badge count here
            application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
            
        case .active:
            print("Active")
            
        }
    }
    
    // setup user device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let myDeviceToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("\(myDeviceToken)")
        
        userDeviceToken = myDeviceToken
    }
    
    // handle push notification presentation
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler( [.alert, .badge, .sound] )
    }
}

