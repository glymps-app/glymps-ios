//
//  FeedAPI.swift
//  GlympsApp
//
//  Created by Luckhardt, Charles on 10/3/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class FeedAPI: APIType {

    let path: String
    let parentReference: DatabaseReference

    init(parent: DatabaseReference, user: FirebaseAuth.User) {
        self.path = "feeds/\(user.uid)"
        self.parentReference = parent
    }

    func parseResponse(_ snapshot: DataSnapshot) -> [String: CGFloat] {
        return snapshot.value as? [String: CGFloat] ?? [:]
    }
}
