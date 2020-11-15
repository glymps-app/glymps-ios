//
//  UserAPI.swift
//  GlympsApp
//
//  Created by James B Morris on 5/20/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// an API for retrieving/setting up users
class UserAPI {
    
    var REF_USERS = Database.database().reference().child("users") // database address
    
    var CURRENT_USER = Auth.auth().currentUser // classification of app's current user

    func getUser(withId uid: String, completion: @escaping (Result<User, Error>) -> Void) {

        REF_USERS.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            let user = User.transformUser(dict: snapshot.value as? [String : Any] ?? [:], key: snapshot.key)
            completion(.success(user))
        }, withCancel: { error in
            completion(.failure(error))
        })
    }

    func observeCurrentUser(completion: @escaping (User) -> Void) { // observe and identify who app's current User is, and get userId + User object (model)
        guard let currentUser = Auth.auth().currentUser else {
            //assert(false, "current user is nil")
            return
        }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                if user.id! == API.User.CURRENT_USER?.uid {
                    completion(user)
                }else{
                    //assert(false, "user id is nil")
                    return
                }
            }else{
                //assert(false, "snapshot is not a dictionary")
                //completion(nil)
                return
            }
        })
    }
    
    func observeUsers(withId uid: String, completion: @escaping (User) -> Void) { // observe User activity based on their userId
        REF_USERS.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }else{
                print(snapshot.exists(),snapshot.hasChildren())
            }
        })
    }
    
    func observeUsersWithinRadius(withId uid: String, completion: @escaping (User) -> Void) { // observe User activity based on their userId
        REF_USERS.child(uid).observe(.childAdded) { snapshot in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }else{
                print(snapshot.exists(),snapshot.hasChildren())
            }
        }
    }
    
    // observe all Users
    func observeUsers(completion: @escaping (User) -> Void) {
        API.User.REF_USERS.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            } else {
                print(snapshot.exists(), snapshot.hasChildren())
            }
        }
    }
    
    var REF_CURRENT_USER: DatabaseReference? { // database classification of app's current user
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        
        return REF_USERS.child(currentUser.uid)
    }

    
    
    
}
