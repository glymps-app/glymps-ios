//
//  API.swift
//  GlympsApp
//
//  Created by James B Morris on 5/20/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation

// structure for organizing Glymps's in-app APIs
struct API {
    static var User = UserAPI()
    static var Messages = MessagesAPI()
    static var Inbox = InboxAPI()
}
