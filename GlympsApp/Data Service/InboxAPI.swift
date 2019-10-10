//
//  InboxAPI.swift
//  GlympsApp
//
//  Created by James B Morris on 8/15/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// an API for inbox activities
class InboxAPI {
    
    // save message requests to Firebase
    func saveRequest(uid: String) {
    Database.database().reference().child("messageRequests").child(uid).updateChildValues([API.User.CURRENT_USER!.uid:1])
    }
    
    // save matches to Firebase
    func saveMatch(uid: String) {
    Database.database().reference().child("matches").child(API.User.CURRENT_USER!.uid).updateChildValues([uid:1])
    Database.database().reference().child("matches").child(uid).updateChildValues([API.User.CURRENT_USER!.uid:1])

    }
    
    // block current user from seeing another User's profile for 24 hours
    func blockUser(uid: String) {
        
        Database.database().reference().child("blocking").child(API.User.CURRENT_USER!.uid).updateChildValues([uid:Int(Date().timeIntervalSince1970)])
        
        Database.database().reference().child("blocking").child(uid).updateChildValues([API.User.CURRENT_USER!.uid:Int(Date().timeIntervalSince1970)])
        
    }
    
    func permanentlyBlockUser(uid: String) {
        
        Database.database().reference().child("permanent-blocks").child(API.User.CURRENT_USER!.uid).updateChildValues([uid:true])
        
        Database.database().reference().child("permanent-blocks").child(uid).updateChildValues([API.User.CURRENT_USER!.uid:true])
        
    }
    
    // load message requests
    func loadMessageRequests(completion: @escaping (User) -> Void) {
        Database.database().reference().child("messageRequests").child(API.User.CURRENT_USER!.uid).observe(.value) { (snapshot) in
            if (snapshot.value as? [String : Any]) != nil {
                if let dict = snapshot.value as? Dictionary<String,Any> {
                    for userId in dict.keys {
                        API.User.observeUsers(withId: userId, completion: { (user) in
                            completion(user)
                        })
                    }
                }
            }
        }
    }
    
    // get other user's deviceToken (for sending notifications)
    func loadUserDeviceToken(uid: String, completion: @escaping (String) -> Void) {
        
        Database.database().reference().child("deviceTokens").child(uid).observe(.value) { (snapshot) in
            if (snapshot.value as? [String : Any]) != nil {
                if let dict = snapshot.value as? Dictionary<String,Any> {
                    let deviceToken = dict["deviceToken"] as! String
                    completion(deviceToken)
                }
            }
        }
    }
    
    // load message requests on card deck controller
    func loadMessageRequestsDeck(completion: @escaping (User) -> Void) {
        Database.database().reference().child("messageRequests").child(API.User.CURRENT_USER!.uid).observe(.value) { (snapshot) in
            if (snapshot.value as? [String : Any]) != nil {
                if let dict = snapshot.value as? Dictionary<String,Any> {
                    for userId in dict.keys {
                        API.User.observeUsers(withId: userId, completion: { (user) in
                            completion(user)
                        })
                    }
                }
            }
        }
    }
    
    // load blocks on card deck controller
    func loadBlockedUsersDeck(completion: @escaping (Any) -> Void) {
        
    Database.database().reference().child("blocking").child(API.User.CURRENT_USER!.uid).observe(.value) { (snapshot) in
            if (snapshot.value as? [String : Any]) != nil {
                if let dict = snapshot.value as? Dictionary<String,Any> {
                    for date in dict.values {
                        let blockedDate = date as! Int
                        let currentDate = Int(Date().timeIntervalSince1970)
                        let hours = (currentDate - blockedDate) / 3600
                        if hours <= 24 {
                            print("Hours since block: \(hours)")
                            for userId in dict.keys {
                                API.User.observeUsers(withId: userId, completion: { (user) in
                                    completion(user)
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    // load permanent blocks on card deck controller
    func loadPermanentlyBlockedUsersDeck(completion: @escaping (Any) -> Void) {
    Database.database().reference().child("permanent-blocks").child(API.User.CURRENT_USER!.uid).observe(.value) { (snapshot) in
            if (snapshot.value as? [String : Any]) != nil {
                if let dict = snapshot.value as? Dictionary<String,Any> {
                    for userId in dict.keys {
                        API.User.observeUsers(withId: userId, completion: { (user) in
                            completion(user)
                        })
                    }
                }
            }
        }
    }
    
    // remove specific message request (used on blocking)
    func removeMessageRequest(uid: String) {
        Database.database().reference().child("messageRequests").child(API.User.CURRENT_USER!.uid).child(uid).setValue(nil)
    }
    
    // remove specific match (used on blocking)
    func removeMatch(uid: String) {
        
        Database.database().reference().child("matches").child(API.User.CURRENT_USER!.uid).child(uid).setValue(nil)
        
        Database.database().reference().child("matches").child(uid).child(API.User.CURRENT_USER!.uid).setValue(nil)
    }
    
    // remove specific conversation (used on blocking)
    func removeMessages(uid: String) {
        
        Database.database().reference().child("messages").child(API.User.CURRENT_USER!.uid).child(uid).setValue(nil)
        
        Database.database().reference().child("messages").child(uid).child(API.User.CURRENT_USER!.uid).setValue(nil)
    }
    
    // load all matches
    func loadMatches(completion: @escaping (User) -> Void) {
        Database.database().reference().child("matches").child(API.User.CURRENT_USER!.uid).observe(.value) { (snapshot) in
            if (snapshot.value as? [String : Any]) != nil {
                if let dict = snapshot.value as? Dictionary<String,Any> {
                    for userId in dict.keys {
                        API.User.observeUsers(withId: userId, completion: { (user) in
                            completion(user)
                        })
                    }
                }
            }
        }
    }
    
    // load matches on card deck controller
    func loadMatchesDeck(completion: @escaping (User) -> Void) {
        Database.database().reference().child("matches").child(API.User.CURRENT_USER!.uid).observe(.value) { (snapshot) in
            if (snapshot.value as? [String : Any]) != nil {
                if let dict = snapshot.value as? Dictionary<String,Any> {
                    for userId in dict.keys {
                        API.User.observeUsers(withId: userId, completion: { (user) in
                            completion(user)
                        })
                    }
                }
            }
        }
    }
    
    
    
}
