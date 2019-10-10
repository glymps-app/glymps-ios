//
//  User.swift
//  Glymps
//
//  Created by James B Morris on 4/30/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// A user of Glymps and their attributes
class User {
    
    var email: String?
    var age: Int?
    var profession: String?
    var company: String?
    var profileImages: [String]?
    var name: String?
    var gender: String?
    var id: String?
    var bio: String?
    var coins: Int?
    var isPremium: Bool?
    var minAge: Int?
    var maxAge: Int?
    var preferedGender: String?
}

enum Gender: String {
    case male = "Male"
    case female = "Female"
}

struct GenderPreference {

    let genders: [Gender]

    init(rawValue: String) {
        switch rawValue {
        case "Male":
            genders = [.male]
        case "Female":
            genders = [.female]
        case "Both":
            genders = [.male, .female]
        default:
            genders = []
        }
    }

    func matches(_ gender: Gender) -> Bool {
        return genders.contains(where: { $0 == gender })
    }
}


extension User {

    // A function for transforming the dictionary formats of a Glymps user's attributes from Firebase into a single, simplified User object
    static func transformUser(dict: [String : Any], key: String) -> User {
        let user = User()
        user.email = dict["email"] as? String
        user.age = dict["age"] as? Int
        user.profession = dict["profession"] as? String
        user.company = dict["company"] as? String
        user.profileImages = dict["profileImages"] as? [String]
        user.name = dict["name"] as? String
        user.gender = dict["gender"] as? String
        user.id = key
        user.bio = dict["bio"] as? String
        user.coins = dict["coins"] as? Int
        user.isPremium = dict["isPremium"] as? Bool
        user.minAge = dict["minAge"] as? Int
        user.maxAge = dict["maxAge"] as? Int
        user.preferedGender = dict["preferedGender"] as? String
        
        return user
    }
}

// Extension supplement for the function above so the key off Firebase (a user ID string) is guaranteed to be in correct format for the function
extension Dictionary where Key == String {}
