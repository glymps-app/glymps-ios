//
//  Constants.swift
//  GlympsApp
//
//  Created by James B Morris on 8/25/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation


// Constants


// bundle identifier for Glymps iOS
let kBundleID = Bundle.main.bundleIdentifier!

// Constants for Git Login


// endpoint for notification server
let requestString = "https://glymps.herokuapp.com/send.js"


// user deviceToken, set when application launches to enable notification delivery
var userDeviceToken = ""
