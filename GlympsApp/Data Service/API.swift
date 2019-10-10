//
//  API.swift
//  GlympsApp
//
//  Created by James B Morris on 5/20/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

// structure for organizing Glymps's in-app APIs
struct API {
    static var User = UserAPI()
    static var Messages = MessagesAPI()
    static var Inbox = InboxAPI()
}

class AuthAPI {

    let user: FirebaseAuth.User
    let reference: DatabaseReference = Database.database().reference()

    lazy private(set) var feed = FeedAPI(parent: reference, user: user)
    lazy private(set) var location = LocationAPI(parent: reference, user: user)

    init(user: FirebaseAuth.User) {
        self.user = user
    }
}
