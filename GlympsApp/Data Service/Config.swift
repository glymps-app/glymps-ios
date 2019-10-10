//
//  Config.swift
//  GlympsApp
//
//  Created by James B Morris on 5/20/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file instantiates a direct backend url to connect Glymps to the backend database/server (Google Firebase).


// endpoint url for Glymps's Google Firebase Database
struct Config {
    static var STORAGE_ROOT_REF = "gs://glymps-a02f6.appspot.com"
}
