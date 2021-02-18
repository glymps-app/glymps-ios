//
//  AuthService.swift
//  Glymps
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

// This file acts as a storage file for all functions with backend functionality relative to User Authentication, including Sign In, Sign Up, Update User Data, and Log Out.

class AuthService {
    
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) { // authenticate and sign in User into app
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if (error != nil) {
                onError()
            } else {
                onSuccess()
            }
        }
    }
    
    static func signUp(name: String, gender: String, email: String, password: String, age: Int, bio: String, profession: String, company: String, coins: Int, isPremium: Bool, minAge: Int, maxAge: Int, preferedGender: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) { // authenticate and sign up User for app
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if (error != nil) {
                onError()
            } else {
                let uid = Auth.auth().currentUser!.uid
                
                // store profile image
                let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profileImage").child(uid).child("profileImage1")
                
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    guard metadata != nil else {
                        print("Error occurred.")
                        return
                    }
                    storageRef.downloadURL { (url, error) in
                        guard (url) != nil else {
                            print("Error occurred.")
                            return
                        }
                        self.updateUserInformation(url: [url!.absoluteString], name: name, gender: gender, email: email, age: age, bio: bio, profession: profession, company: company, coins: coins, isPremium: isPremium, minAge: minAge, maxAge: maxAge, preferedGender: preferedGender, uid: uid, onSuccess: onSuccess)
                    }
                })
            }
        }
    }
    
    static func updateUserInformation(url: [String], name: String, gender: String, email: String, age: Int, bio: String, profession: String, company: String, coins: Int, isPremium: Bool, minAge: Int, maxAge: Int, preferedGender: String, uid: String, onSuccess: @escaping () -> Void) { // update key User information such as username, email, artforms, bio, and profile image, with User inputs
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newReference = usersReference.child(uid)
        newReference.setValue(["name" : name, "age" : age, "gender" : gender, "email" : email, "bio" : bio, "profession" : profession, "company" : company, "coins" : coins, "isPremium" : isPremium, "minAge" : minAge, "maxAge" : maxAge, "preferedGender" : preferedGender, "profileImages" : url])
        onSuccess()
    }
    
    static func updateUserInfo(name: String, gender: String, age: Int, email: String, bio: String, profession: String, company: String, imageData: [Data], onSuccess: @escaping () -> Void, onError: @escaping () -> Void) { // update key User information such as username, email, artforms, bio, and profile image
        
        var profileImages: [String] = []

        API.User.CURRENT_USER?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError()
                print("Error: \(String(describing: error?.localizedDescription))")
            } else {
                let uid = API.User.CURRENT_USER?.uid

                // store profile images (when multiple are chosen in Edit Profile)
                let storageRef1 = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profileImage").child(uid!).child("profileImage1")
                let storageRef2 = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profileImage").child(uid!).child("profileImage2")
                let storageRef3 = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profileImage").child(uid!).child("profileImage3")
                
                
                let index0 = 0
                let index1 = 1
                let index2 = 2
                
                if index0 == 0 && index0 < imageData.count {
                    storageRef1.putData(imageData[index0], metadata: nil, completion: { (metadata, error) in
                        guard metadata != nil else {
                            print("No metadata.")
                            return
                        }
                        storageRef1.downloadURL { (url, error) in
                            guard (url) != nil else {
                                print("Reference URL does not exist.")
                                return
                            }
                            
                            let profileImageUrl1 = url?.absoluteString
                            profileImages.append(profileImageUrl1!)
                            
                            print("1: \(String(describing: profileImageUrl1))")
                            
                        }
                    })
                }
                
                if index1 >= 0 && index1 < imageData.count {
                    storageRef2.putData(imageData[index1], metadata: nil, completion: { (metadata, error) in
                        guard metadata != nil else {
                            print("No metadata.")
                            return
                        } // function above and function below take chosen image data and transform to url and pushes url to storage on database
                        storageRef2.downloadURL { (url, error) in
                            guard (url) != nil else {
                                print("Reference URL does not exist.")
                                return
                            }
                            
                            let profileImageUrl2 = url?.absoluteString
                            profileImages.append(profileImageUrl2!)
                            
                            print("2: \(String(describing: profileImageUrl2))")
                            
                        }
                    })
                }
                
                if index2 >= 0 && index2 < imageData.count {
                    storageRef3.putData(imageData[index2], metadata: nil, completion: { (metadata, error) in
                        guard metadata != nil else {
                            print("No metadata.")
                            return
                        }
                        storageRef3.downloadURL { (url, error) in
                            guard (url) != nil else {
                                print("Reference URL does not exist.")
                                return
                            }
                            
                            let profileImageUrl3 = url?.absoluteString
                            profileImages.append(profileImageUrl3!)
                            
                            print("3: \(String(describing: profileImageUrl3))")
                            
                        }
                    })
                }
                
                // update UI based on saved data
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    print("Profile Images: \(profileImages)")
                    self.updateDatabase(url: profileImages, name: name, gender: gender, age: age, email: email, bio: bio, profession: profession, company: company, onSuccess: onSuccess, onError: onError)
                })
            }
        })
    }

    static func updateDatabase(url: [String], name: String, gender: String, age: Int, email: String, bio: String, profession: String, company: String, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) { // update key User information such as username, email, bio, and profile image, on database

        let dict = ["name" : name, "gender" : gender, "age" : age, "email" : email, "bio" : bio, "profession" : profession, "company" : company, "profileImages" : url] as [String : Any]

        API.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError()
                print("Error: \(String(describing: error?.localizedDescription))")
            } else {
                onSuccess()
                print("Success!")
            }
        })
    }
    
    // update user settings to Firebase
    static func updateSettings(minAge: Int, maxAge: Int, preferedGender: String) {
        Database.database().reference().child("users").child(API.User.CURRENT_USER!.uid).updateChildValues(["minAge" : minAge]) { (error, ref) in }
        Database.database().reference().child("users").child(API.User.CURRENT_USER!.uid).updateChildValues(["maxAge" : maxAge]) { (error, ref) in }
        Database.database().reference().child("users").child(API.User.CURRENT_USER!.uid).updateChildValues(["preferedGender" : preferedGender]) { (error, ref) in }
    }
    
    // save user settings
    static func saveSettings(minAge: Int, maxAge: Int, preferedGender: String, onSuccess: @escaping () -> Void) {
        
        updateSettings(minAge: minAge, maxAge: maxAge, preferedGender: preferedGender)
        
        onSuccess()
    }
    
    // update current user's coin amount
    static func updateCoins(coinAmount: Int) {
        Database.database().reference().child("users").child(API.User.CURRENT_USER!.uid).updateChildValues(["coins" : coinAmount]) { (error, ref) in }
    }
    
    // subscribe User to Glymps Premium
    static func subscribe() {
        
        Database.database().reference().child("users").child(API.User.CURRENT_USER!.uid).updateChildValues(["isPremium" : true]) { (error, ref) in }
    }
    
    // unsubscribe User from Glymps Premium if they cancel subscription or subscription runs out
    static func unsubscribe() {
        
        Database.database().reference().child("users").child(API.User.CURRENT_USER!.uid).updateChildValues(["isPremium" : false]) { (error, ref) in }
        
    }
    
    static func logout(onSuccess: @escaping () -> Void, onError: @escaping () -> Void) { // authenticate and log out User from app
        
        do {
            try Auth.auth().signOut()
            Auth.auth().addStateDidChangeListener { (auth, user) in
                if auth.currentUser == nil {
                    onSuccess()
                }
            }
            
        } catch let logoutError {
            print(logoutError.localizedDescription)
        }
    }
    
    
}
