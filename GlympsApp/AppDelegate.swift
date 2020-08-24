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
import PushNotifications
//import SmaatoSDKCore
//import SmaatoSDKBanner
//import SmaatoSDKInterstitial
import Purchases
import FirebaseDynamicLinks

// entire application config for Glymps iOS
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        beamsClient.start(instanceId: "bfb3dfa2-8c01-4647-a156-71e369bbae73")
        beamsClient.registerForRemoteNotifications()
        
        // remove notifications already delivered
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // initialize RevenueCat iOS SDK
        Purchases.debugLogsEnabled = true
        Purchases.configure(withAPIKey: "EEQPqlAIaJUkdxWjqhkqvprTQmKSbHEZ", appUserID: nil)
//        
//        // initialize Smaato iOS SDK
//        guard let config = SMAConfiguration(publisherId: "0") else {
//                fatalError("SDK config is nil!")
//        }
//        config.httpsOnly = true // allow HTTPS traffic only
//        config.logLevel = .error // log errors only
//        SmaatoSDK.initSDK(withConfig: config)
        
        // Override point for customization after application launch, initialize Firebase iOS SDK
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
//        if Auth.auth().currentUser != nil {
//            goToMain()
//        } else {
//            goToLogin()
//        }
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.goToMain()
            } else {
                self.goToLogin()
            }
        }
        
        return true
    }
    
    func goToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()!
        self.window = UIWindow(frame:UIScreen.main.bounds)
        window!.rootViewController = initial
        window!.makeKeyAndVisible()
    }
    
    func goToLogin() {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()!
        self.window = UIWindow(frame:UIScreen.main.bounds)
        window!.rootViewController = initial
        window!.makeKeyAndVisible()
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        
        guard let url = dynamicLink.url else {
            print("Whoops! This dynamic link does not contain a URL...")
            return
        }
        print("Welcome! Your referring URL: \(url.absoluteString)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else { return }
        
        for queryItem in queryItems {
            if queryItem.name == "referringUser" {
                print("You've been referred by \(queryItem.value ?? "No user found :(")")
                
                // Handle the deep link.
                // Set referralUID string on sign up to referring user's UID (from path of referral URL). Pass through the onboarding process and increase that user's coin amount by 3 after the user finishes sign up.
                referringUser = queryItem.value ?? ""
            }
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            print("Incoming URL is \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else {
                    print("Found an error: \(error!.localizedDescription)")
                    return
                }
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
            if linkHandled {
                return true
            } else {
                // Maybe do something else with this URL?
                return false
            }
        }
        return false
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        print("I have received a URL through a custom scheme! \(url.absoluteString)")
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handleIncomingDynamicLink(dynamicLink)
            return true
        } else {
            // Maybe handle Google or Facebook sign-in auth here?
            return false
        }
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
        
        beamsClient.handleNotification(userInfo: userInfo)
        
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // handle tapped user notifications
        
        if API.User.CURRENT_USER != nil {
            
            API.User.observeCurrentUser { (user) in
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                // instantiate the view controller from storyboard
                if let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {

                    // set the view controller as root
                    chatVC.userId = response.notification.request.content.userInfo["user_id"] as? String
                    chatVC.currentUsername = user.name
                    chatVC.currentUser = user
                    self.window?.rootViewController?.present(chatVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    // setup user device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        beamsClient.registerDeviceToken(deviceToken)
    }
    
    // handle push notification presentation
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler( [.alert, .badge, .sound] )
    }
}

