//
//  LocationAPI.swift
//  GlympsApp
//
//  Created by Luckhardt, Charles on 10/9/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class LocationAPI: APIType {

    let path: String
    let parentReference: DatabaseReference

    init(parent: DatabaseReference, user: FirebaseAuth.User) {
        self.path = "Geolocs/\(user.uid)"
        self.parentReference = parent
    }

    func parseResponse(_ snapshot: DataSnapshot) -> Void {
    }

    func addTimestamp() {
        reference.updateChildValues(["timestamp": Date()])
    }
}
