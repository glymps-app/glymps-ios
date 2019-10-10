//
//  BlockUserVC.swift
//  GlympsApp
//
//  Created by James B Morris on 8/22/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// popover for current user to block another user and go into "ghost mode", where they disappear out of the other user's view immediately, and for the next 24 hours
class BlockUserVC: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var declineUserBtn: UIButton!
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    var userId: String?
    
    var userDetailsVC: UserDetailsVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        UserDefaults.standard.removeObject(forKey: "\(self.userId!)")
        UserDefaults.standard.removeObject(forKey: "\(self.userId!):match")
        API.Inbox.removeMessageRequest(uid: self.userId!)
        API.Inbox.removeMatch(uid: self.userId!)
        API.Inbox.removeMessages(uid: self.userId!)
        API.Inbox.blockUser(uid: self.userId!)
        
        dismiss(animated: true, completion: nil)
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let deckVC = storyboard.instantiateViewController(withIdentifier: "DeckVC")
        self.userDetailsVC!.present(deckVC, animated: true, completion: nil)
    }
    
    // decline and block other user for 24 hours, and remove them as request, match as accordingly, also remove any existing conversations
    @IBAction func declineUserBtnWasPressed(_ sender: Any) {
        declineUser()
    }
    
     // dismiss popover
    @IBAction func dismissBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
