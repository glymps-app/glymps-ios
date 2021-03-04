//
//  BlockUserVC.swift
//  GlympsApp
//
//  Created by James B Morris on 8/22/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import Amplitude_iOS

// popover for current user to block another user and go into "ghost mode", where they disappear out of the other user's view immediately, and for the next 24 hours
class BlockUserVC: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var declineUserBtn: UIButton!
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var dropView: UIView!
    
    var userId: String?
    
    var userDetailsVC: UserDetailsVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logAmplitudeBlockUserViewEvent()
        
        dropView.dropShadow(color: .darkGray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 20, scale: true)
        
        usernameLabel.text = ""
        setupLabel()
    }
    
    // setup popover
    func setupLabel() {
        API.User.observeUsers(withId: self.userId!) { (user) in
            self.usernameLabel.text = "Drop \(user.name!) for 24 hours?"
        }
    }
    
    // decline and block other user for 24 hours, and remove them as request, match as accordingly, also remove any existing conversations
    func declineUser() {
        API.Inbox.blockUser(uid: self.userId!)
        self.logAmplitudeCardBlockEvent(userId: self.userId!)
        dismiss(animated: true, completion: nil)
        if let p = self.userDetailsVC!.presenter as? DeckVC {
            // TODO: reload and refresh card deck below
            p.blockFromOtherVC()
        }
        self.userDetailsVC!.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            self.tabBarController?.selectedIndex = 1
        })
    }
    
    func logAmplitudeCardBlockEvent(userId: String) {
        API.User.observeUsers(withId: userId) { (user) in
            var userBlockedEventProperties: [AnyHashable : Any] = [:]
            userBlockedEventProperties.updateValue(user.email as Any, forKey: "Email")
            userBlockedEventProperties.updateValue(user.age as Any, forKey: "Age")
            userBlockedEventProperties.updateValue(user.profession as Any, forKey: "Profession")
            userBlockedEventProperties.updateValue(user.company as Any, forKey: "Company")
            userBlockedEventProperties.updateValue(user.name as Any, forKey: "Name")
            userBlockedEventProperties.updateValue(user.gender as Any, forKey: "Gender")
            userBlockedEventProperties.updateValue(user.id as Any, forKey: "User ID")
            userBlockedEventProperties.updateValue(user.coins as Any, forKey: "Number of Glymps Coins")
            userBlockedEventProperties.updateValue(user.isPremium as Any, forKey: "Subscription Status")
            userBlockedEventProperties.updateValue(user.minAge as Any, forKey: "Minimum Preferred Age")
            userBlockedEventProperties.updateValue(user.maxAge as Any, forKey: "Maximum Preferred Age")
            userBlockedEventProperties.updateValue(user.preferedGender as Any, forKey: "Preferred Gender")
            userBlockedEventProperties.updateValue("BlockUser VC", forKey: "Origin Screen")
            Amplitude.instance().logEvent("User Blocked", withEventProperties: userBlockedEventProperties)
        }
    }
    
    func logAmplitudeBlockUserViewEvent() {
        Amplitude.instance().logEvent("Block User View")
    }
    
    // decline and block other user for 24 hours, and remove them as request, match as accordingly, also remove any existing conversations
    @IBAction func declineUserBtnWasPressed(_ sender: Any) {
        declineUser()
    }
    
     // dismiss popover
    @IBAction func dismissBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
