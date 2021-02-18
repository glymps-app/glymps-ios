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
import Amplitude_iOS

// an API for inbox activities
class InboxAPI {
    
    // save message requests to Firebase
    func saveRequest(uid: String) {
        Database.database().reference().child("messageRequests").child(uid).updateChildValues([API.User.CURRENT_USER!.uid:1])
        self.logAmplitudeRequestEvent(userId: uid)
    }
    
    // save matches to Firebase
    func saveMatch(uid: String) {
        Database.database().reference().child("matches").child(API.User.CURRENT_USER!.uid).updateChildValues([uid:1])
        Database.database().reference().child("matches").child(uid).updateChildValues([API.User.CURRENT_USER!.uid:1])
        self.logAmplitudeMatchEvent(userId: uid)
    }
    
    // block current user from seeing another User's profile for 24 hours
    func blockUser(uid: String) {
        UserDefaults.standard.removeObject(forKey: "\(uid)")
        UserDefaults.standard.removeObject(forKey: "\(uid):match")
        removeMessageRequest(uid: uid)
        removeMatch(uid: uid)
        removeMessages(uid: uid)
        Database.database().reference().child("blocking").child(API.User.CURRENT_USER!.uid).updateChildValues([uid:Int(Date().timeIntervalSince1970)])

        Database.database().reference().child("blocking").child(uid).updateChildValues([API.User.CURRENT_USER!.uid:Int(Date().timeIntervalSince1970)])

    }
    
    func flagUser(uid: String, reason: String) {
        Database.database().reference().child("flagged-users").child(uid).setValue(["userId" : uid, "flaggedBecause" : reason])
    }
    
    // go into "Ghost Mode": where no one can see your profile for 24 hours. Can be turned off and on
    func goIntoGhostMode(competion: @escaping () -> Void) {
        Database.database().reference().child("ghost-mode").child(API.User.CURRENT_USER!.uid).updateChildValues([API.User.CURRENT_USER!.uid:Int(Date().timeIntervalSince1970)])
    }
    
    // go out of "Ghost Mode"
    func goOutOfGhostMode(completion: @escaping () -> Void) {
        Database.database().reference().child("ghost-mode").child(API.User.CURRENT_USER!.uid).removeValue()
    }
    
    // block another user forever
    func permanentlyBlockUser(uid: String) {
        UserDefaults.standard.removeObject(forKey: "\(uid)")
        UserDefaults.standard.removeObject(forKey: "\(uid):match")
        removeMessageRequest(uid: uid)
        removeMatch(uid: uid)
        removeMessages(uid: uid)
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
    
    // load users in "Ghost Mode" on card deck controller
    func loadUsersInGhostMode(completion: @escaping (Any) -> Void) {
        
        Database.database().reference().child("ghost-mode").observe(.value) { (snapshot) in
            if (snapshot.value as? [String : Any]) != nil {
                if let dict = snapshot.value as? Dictionary<String,Any> {
                    for v in dict.values {
                        
                        let date = "\(v)".slice(from: "= ", to: ";")
                        let ghostModeDate = Int(date!)
                        let currentDate = Int(Date().timeIntervalSince1970)
                        let hours = (currentDate - ghostModeDate!) / 3600
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
    
    // see if current user is in "Ghost Mode"
    func isInGhostMode(completion: @escaping (Bool) -> Void) {
        
        Database.database().reference().child("ghost-mode").child(API.User.CURRENT_USER!.uid).observe(.value) { (snapshot) in
            if (snapshot.value as? [String : Any]) != nil {
                if let dict = snapshot.value as? Dictionary<String,Any> {
                    for date in dict.values {
                        let ghostModeDate = date as! Int
                        let currentDate = Int(Date().timeIntervalSince1970)
                        let hours = (currentDate - ghostModeDate) / 3600
                        if hours <= 24 {
                            print("Hours since block: \(hours)")
                            for userId in dict.keys {
                                if userId == API.User.CURRENT_USER!.uid {
                                    completion(true)
                                } else {
                                    completion(false)
                                }
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
    
    func logAmplitudeRequestEvent(userId: String) {
        API.User.observeUsers(withId: userId) { (user) in
            var requestEventProperties: [AnyHashable : Any] = [:]
            requestEventProperties.updateValue(user.email as Any, forKey: "Email")
            requestEventProperties.updateValue(user.age as Any, forKey: "Age")
            requestEventProperties.updateValue(user.profession as Any, forKey: "Profession")
            requestEventProperties.updateValue(user.company as Any, forKey: "Company")
            requestEventProperties.updateValue(user.name as Any, forKey: "Name")
            requestEventProperties.updateValue(user.gender as Any, forKey: "Gender")
            requestEventProperties.updateValue(user.id as Any, forKey: "User ID")
            requestEventProperties.updateValue(user.coins as Any, forKey: "Number of Glymps Coins")
            requestEventProperties.updateValue(user.isPremium as Any, forKey: "Subscription Status")
            requestEventProperties.updateValue(user.minAge as Any, forKey: "Minimum Preferred Age")
            requestEventProperties.updateValue(user.maxAge as Any, forKey: "Maximum Preferred Age")
            requestEventProperties.updateValue(user.preferedGender as Any, forKey: "Preferred Gender")
            Amplitude.instance().logEvent("Request", withEventProperties: requestEventProperties)
        }
    }
    
    func logAmplitudeMatchEvent(userId: String) {
        API.User.observeUsers(withId: userId) { (user) in
            var matchEventProperties: [AnyHashable : Any] = [:]
            matchEventProperties.updateValue(user.email as Any, forKey: "Email")
            matchEventProperties.updateValue(user.age as Any, forKey: "Age")
            matchEventProperties.updateValue(user.profession as Any, forKey: "Profession")
            matchEventProperties.updateValue(user.company as Any, forKey: "Company")
            matchEventProperties.updateValue(user.name as Any, forKey: "Name")
            matchEventProperties.updateValue(user.gender as Any, forKey: "Gender")
            matchEventProperties.updateValue(user.id as Any, forKey: "User ID")
            matchEventProperties.updateValue(user.coins as Any, forKey: "Number of Glymps Coins")
            matchEventProperties.updateValue(user.isPremium as Any, forKey: "Subscription Status")
            matchEventProperties.updateValue(user.minAge as Any, forKey: "Minimum Preferred Age")
            matchEventProperties.updateValue(user.maxAge as Any, forKey: "Maximum Preferred Age")
            matchEventProperties.updateValue(user.preferedGender as Any, forKey: "Preferred Gender")
            Amplitude.instance().logEvent("Match", withEventProperties: matchEventProperties)
        }
    }
    
    
    
}
