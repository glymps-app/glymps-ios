//
//  DeclineUserVC.swift
//  GlympsApp
//
//  Created by James B Morris on 8/19/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// popover for current user to block another user and go into "ghost mode", where they disappear out of the other user's view immediately, and for the next 24 hours
class DeclineUserVC: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var declineUserBtn: UIButton!
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    var userId: String?
    
    var chatVC: ChatVC?

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
        API.Inbox.blockUser(uid: self.userId!)
        
        dismiss(animated: true, completion: nil)
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessagesVC")
        self.chatVC!.present(messagesVC, animated: true, completion: nil)
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
