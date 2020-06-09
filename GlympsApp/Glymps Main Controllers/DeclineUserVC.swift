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
    
    @IBOutlet weak var dropView: UIView!
    
    var userId: String?
    
    var chatVC: ChatVC?
    
    var deckVC: UIViewController?
    
    var messagesVC: UIViewController?
    
    var cardView: CardView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        dismiss(animated: true, completion: nil)
        if let d = self.deckVC as? DeckVC {
            // TODO: reload and refresh card deck below
            d.blockFromOtherVC()
            
            self.chatVC!.navigationController?.popToViewController(d, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.tabBarController?.selectedIndex = 1
            })
        } else if let m = self.messagesVC as? MessagesVC {
            m.loadNewMessages()
            m.loadMatches()
            m.tableView.reloadData()
            m.collectionView.reloadData()
            
            self.chatVC!.navigationController?.popToViewController(m, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.tabBarController?.selectedIndex = 2
            })
        }
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
