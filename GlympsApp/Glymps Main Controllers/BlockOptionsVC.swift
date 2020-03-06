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
    
    @IBOutlet weak var dropView: UIView!
    
    var userId: String?
    
    var userDetailsVC: UserDetailsVC?
    
    var chatVC: ChatVC?
    
    var deckVC: UIViewController?
    
    var cardView: CardView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropView.dropShadow(color: .darkGray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 20, scale: true)

        usernameLabel.text = ""
        setupLabel()
        print(chatVC)
    }
    
    func setupLabel() {
        API.User.observeUsers(withId: self.userId!) { (user) in
            self.usernameLabel.text = "Block \(user.name!)..."
        }
    }
    
    func blockAction() {
        API.Inbox.permanentlyBlockUser(uid: self.userId!)
        
        if self.userDetailsVC != nil {
            dismiss(animated: true, completion: nil)
            if let p = self.userDetailsVC!.presenter as? DeckVC {
                // TODO: reload and refresh card deck below
                p.cardViews.remove(at: (userDetailsVC?.cardView.tag)!)
                p.cardsDeckView.reloadData()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessagesVC") as! MessagesVC
                messagesVC.loadNewMessages()
                messagesVC.loadMatches()
            }
            self.userDetailsVC!.dismiss(animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.tabBarController?.selectedIndex = 1
            })
        } else if self.chatVC != nil {
            dismiss(animated: true, completion: nil)
            if let d = self.deckVC as? DeckVC {
                // TODO: reload and refresh card deck below
                d.cardViews.remove(at: (self.cardView?.tag)!)
                d.cardsDeckView.reloadData()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessagesVC") as! MessagesVC
                messagesVC.loadNewMessages()
                messagesVC.loadMatches()
                
                self.chatVC!.navigationController?.popToViewController(d, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    self.tabBarController?.selectedIndex = 1
                })
            }
        } else { return }
    }
    
    @IBAction func blockForeverBtnWasPressed(_ sender: Any) {
        blockAction()
    }
    
    @IBAction func blockTemporarilyBtnWasPressed(_ sender: Any) {
        
        if self.userDetailsVC != nil {
            dismiss(animated: true, completion: nil)
            self.tabBarController?.tabBar.isHidden = false
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
            declineUserVC.deckVC = self.deckVC
            declineUserVC.cardView = self.cardView
            self.chatVC!.present(declineUserVC, animated: true, completion: nil)
        } else { return }
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    


}
