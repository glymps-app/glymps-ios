//
//  BlockOptionsVC.swift
//  GlympsApp
//
//  Created by James B Morris on 9/29/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

class BlockOptionsVC: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var blockForeverBtn: UIButton!
    
    @IBOutlet weak var blockTemporarilyBtn: UIButton!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    var userId: String?
    
    var userDetailsVC: UserDetailsVC?
    
    var chatVC: ChatVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameLabel.text = ""
        setupLabel()
    }
    
    func setupLabel() {
        API.User.observeUsers(withId: self.userId!) { (user) in
            self.usernameLabel.text = "Block \(user.name!)..."
        }
    }
    
    func blockAction() {
        UserDefaults.standard.removeObject(forKey: "\(self.userId!)")
        UserDefaults.standard.removeObject(forKey: "\(self.userId!):match")
        API.Inbox.removeMessageRequest(uid: self.userId!)
        API.Inbox.removeMatch(uid: self.userId!)
        API.Inbox.removeMessages(uid: self.userId!)
        API.Inbox.permanentlyBlockUser(uid: self.userId!)
        
        dismiss(animated: true, completion: nil)
        
        if self.userDetailsVC != nil {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromTop
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let deckVC = storyboard.instantiateViewController(withIdentifier: "DeckVC")
            self.userDetailsVC!.present(deckVC, animated: true, completion: nil)
        } else if self.chatVC != nil {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessagesVC")
            self.chatVC!.present(messagesVC, animated: true, completion: nil)
        } else { return }
    }
    
    @IBAction func blockForeverBtnWasPressed(_ sender: Any) {
        blockAction()
    }
    
    @IBAction func blockTemporarilyBtnWasPressed(_ sender: Any) {
        
        if self.userDetailsVC != nil {
            dismiss(animated: true, completion: nil)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let blockUserVC = storyboard.instantiateViewController(withIdentifier: "BlockUserVC") as! BlockUserVC
            blockUserVC.userId = self.userId
            blockUserVC.userDetailsVC = self.userDetailsVC
            self.userDetailsVC!.present(blockUserVC, animated: true, completion: nil)
        } else if self.chatVC != nil {
            dismiss(animated: true, completion: nil)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let declineUserVC = storyboard.instantiateViewController(withIdentifier: "DeclineUserVC") as! DeclineUserVC
            declineUserVC.userId = self.userId
            declineUserVC.chatVC = self.chatVC
            self.chatVC!.present(declineUserVC, animated: true, completion: nil)
        } else { return }
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    


}