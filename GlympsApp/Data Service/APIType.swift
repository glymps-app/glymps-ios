//
//  APIType.swift
//  GlympsApp
//
//  Created by Luckhardt, Charles on 10/3/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol APIType: class {
    associatedtype Object

    var path: String { get }
    var reference: DatabaseReference { get }
    var parentReference: DatabaseReference { get }

    func parseResponse(_ snapshot: DataSnapshot) -> Object
    func observe(_ eventType: DataEventType, onUpdate: @escaping (Result<Object, Error>) -> Void) -> Connection
    func observeSingleEvent(_ eventType: DataEventType, onUpdate: @escaping (Result<Object, Error>) -> Void)

}

extension APIType {

    var reference: DatabaseReference {
        return parentReference.child(path)
    }

    func observe(_ eventType: DataEventType, onUpdate: @escaping (Result<Object, Error>) -> Void) -> Connection {
        let handle = reference.observe(eventType, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }
            onUpdate(.success(strongSelf.parseResponse(snapshot)))
        }, withCancel: { error in
            // TODO: Handle errors listed here https://firebase.google.com/docs/storage/ios/handle-errors
            onUpdate(.failure(error))
        })
        return Connection(ref: reference, handle: handle)
    }

    func observeSingleEvent(_ eventType: DataEventType, onUpdate: @escaping  (Result<Object, Error>) -> Void) {
        reference.observeSingleEvent(of: eventType, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }
            onUpdate(.success(strongSelf.parseResponse(snapshot)))
        }, withCancel: { error in
            // TODO: Handle errors listed here https://firebase.google.com/docs/storage/ios/handle-errors
            onUpdate(.failure(error))
        })
    }
}
