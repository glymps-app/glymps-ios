//
//  Connection.swift
//  GlympsApp
//
//  Created by Luckhardt, Charles on 10/3/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Connection {
    let ref: DatabaseReference
    let handle: DatabaseHandle

    func end() {
        ref.removeObserver(withHandle: handle)
    }

    func add(to group: ConnectionGroup) {
        group.connections.append(self)
    }
}

class ConnectionGroup {
    var connections: [Connection] = []

    deinit {
        connections.forEach { $0.end() }
    }
}
