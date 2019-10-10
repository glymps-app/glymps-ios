//
//  Notifications.swift
//  GlympsApp
//
//  Created by James B Morris on 8/25/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications

// Notification object for setting up notifications
class Notify: NSObject {
    
    let deviceToken: String
    let message: String
    
    init(deviceToken: String, message: String) {
        self.deviceToken = deviceToken
        self.message = message
    }
    
    // send notification with JSON parameters to notification server, then request for other user's device to receive a notification
    func SendAPNS() {
        
        // let requestString = (production) ? productionUrl : sandboxUrl
        
        let params: Parameters = [
            "token" : deviceToken,
            "message" : message,
            "app" : Bundle.main.bundleIdentifier!
        ]
        
        Alamofire.request(requestString, method: .get, parameters: params, encoding: URLEncoding.default).response { (response) in
            print(response)
        }
    }
    
}
