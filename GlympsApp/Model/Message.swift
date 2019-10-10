//
//  Message.swift
//  GlympsApp
//
//  Created by James B Morris on 8/7/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// A message a Glymps User sends to another User
class Message {
    
    var id: String
    var from: String
    var to: String
    var date: Double
    var text: String
    var imageUrl: String
    var videoUrl: String
    var height: Double
    var width: Double
    
    init(id: String, from: String, to: String, date: Double, text: String, imageUrl: String, videoUrl: String, height: Double, width: Double) {
        self.id = id
        self.from = from
        self.to = to
        self.date = date
        self.text = text
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        self.height = height
        self.width = width
    }
}

extension Message {
    
    // A function for transforming the dictionary formats of the attributes a Glymps user sends, from Firebase into a single, simplified Message object
    static func transformMessage(dict: [String : Any], key: String) -> Message? {
        guard let from = dict["from"] as? String,
        let to = dict["to"] as? String,
            let date = dict["date"] as? Double else {
                return nil
        }
        
        let text = (dict["text"] as? String) == nil ? "" : (dict["text"]! as! String)
        let imageUrl = (dict["imageUrl"] as? String) == nil ? "" : (dict["imageUrl"]! as! String)
        let videoUrl = (dict["videoUrl"] as? String) == nil ? "" : (dict["videoUrl"]! as! String)
        let height = (dict["height"] as? Double) == nil ? 0 : (dict["height"]! as! Double)
        let width = (dict["width"] as? Double) == nil ? 0 : (dict["width"]! as! Double)
        
        let message = Message(id: key, from: from, to: to, date: date, text: text, imageUrl: imageUrl, videoUrl: videoUrl, height: height, width: width)
        
        return message
    }
}

// Extension supplement for the function above so the key off Firebase (a user ID string) is guaranteed to be in correct format for the function
extension Dictionary where Key == String {}

