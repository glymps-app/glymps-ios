//
//  MessagesAPI.swift
//  GlympsApp
//
//  Created by James B Morris on 8/4/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import AVFoundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import Amplitude_iOS

// an API for retrieving/setting up messages
class MessagesAPI {
    
    // send message to receiving User's userID
    func sendMessage(from: String, to: String, value: Dictionary<String, Any>) {
        self.logAmplitudeMessageEvent()
        let ref = Database.database().reference().child("messages").child(from).child(to)
        ref.childByAutoId().updateChildValues(value)
        
        var dict = value
        if let text = dict["text"] as? String, text.isEmpty {
            dict["imageUrl"] = nil
            dict["height"] = nil
            dict["width"] = nil
        }
        
    }
    
    // save photo message to Firebase storage
    func savePhotoMessage(image: UIImage?, id: String, onSuccess: @escaping (_ value: Any) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        self.logAmplitudeImageMessageEvent()
        if let photo = image {
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("photoMessages").child(id)
            if let data = image?.jpegData(compressionQuality: 0.5) {
                storageRef.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil {
                        onError(error!.localizedDescription)
                    }
                    storageRef.downloadURL(completion: { (url, error) in
                        if let metaImageUrl = url?.absoluteString {
                            let dict: Dictionary<String, Any> = [
                                "imageUrl" : metaImageUrl as Any,
                                "height" : photo.size.height as Any,
                                "width" : photo.size.width as Any,
                                "text" : "" as Any
                            ]
                            onSuccess(dict)
                        }
                    })
                }
            }
        }
    }
    
    // save video message to Firebase storage
    func saveVideoMessage(url: URL, id: String, onSuccess: @escaping (_ value: Any) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        self.logAmplitudeVideoMessageEvent()
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("videoMessages").child(id)
        
        storageRef.putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil {
                onError(error!.localizedDescription)
            }
            storageRef.downloadURL(completion: { (videoUrl, error) in
                if let thumbnailImage = self.thumbnailImageForUrl(url) {
                    self.savePhotoMessage(image: thumbnailImage, id: id, onSuccess: { (value) in
                        
                        if let dict = value as? Dictionary<String, Any> {
                            var dictValue = dict
                            if let videoUrlString = videoUrl?.absoluteString {
                                dictValue["videoUrl"] = videoUrlString
                            }
                            onSuccess(dictValue)
                        }
                        
                    }, onError: { (errorMessage) in
                        onError(errorMessage)
                    })
                }
            })
        }
    }
    
    // save thumbnail image for video message to Firebase storage (to display in chat)
    func thumbnailImageForUrl(_ url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // retrieve all message for a particular two users
    func retrieveMessages(from: String, to: String, onSuccess: @escaping (Message) -> Void) {
        let ref = Database.database().reference().child("messages").child(from).child(to)
        ref.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let message = Message.transformMessage(dict: dict, key: snapshot.key) {
                    onSuccess(message)
                }
            }
        }
    }
    
    func logAmplitudeImageMessageEvent() {
        Amplitude.instance().logEvent("Image Message")
    }
    
    func logAmplitudeVideoMessageEvent() {
        Amplitude.instance().logEvent("Video Message")
    }
    
    func logAmplitudeMessageEvent() {
        Amplitude.instance().logEvent("Message")
    }
}
