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
    
    @IBOutlet weak var flagUserButton: UIButton!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var dropView: UIView!
    
    var userId: String?
    
    var username: String?
    
    var userDetailsVC: UserDetailsVC?
    
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
    
    func setupLabel() {
        API.User.observeUsers(withId: self.userId!) { (user) in
            self.usernameLabel.text = "Block \(user.name!)..."
            self.username = user.name!
        }
    }
    
    func blockAction() {
        API.Inbox.permanentlyBlockUser(uid: self.userId!)
        
        if self.userDetailsVC != nil {
            dismiss(animated: true, completion: nil)
            if let p = self.userDetailsVC!.presenter as? DeckVC {
                // TODO: reload and refresh card deck below
                p.blockFromOtherVC()
                
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
            if let d = self.chatVC!.deckVC as? DeckVC {
                // TODO: reload and refresh card deck below
                d.blockFromOtherVC()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessagesVC") as! MessagesVC
                messagesVC.loadNewMessages()
                messagesVC.loadMatches()
                
                self.chatVC!.navigationController?.popToViewController(d, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    self.tabBarController?.selectedIndex = 1
                })
            } else if let m = self.chatVC!.messagesVC as? MessagesVC {
                m.loadNewMessages()
                m.loadMatches()
                m.tableView.reloadData()
                m.collectionView.reloadData()
                
                self.chatVC!.navigationController?.popToViewController(m, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    self.tabBarController?.selectedIndex = 2
                })
            }
        } else { return }
    }
    
    func temporaryBlockAction() {
        
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
            declineUserVC.messagesVC = self.messagesVC
            declineUserVC.cardView = self.cardView
            self.chatVC!.present(declineUserVC, animated: true, completion: nil)
        } else { return }
        
    }
    
    func flagAction(reason: String) {
        
       API.Inbox.permanentlyBlockUser(uid: self.userId!)
        API.Inbox.flagUser(uid: self.userId!, reason: reason)
        
        if self.userDetailsVC != nil {
            self.dismiss(animated: true, completion: nil)
            if let p = self.userDetailsVC!.presenter as? DeckVC {
                // TODO: reload and refresh card deck below
                p.blockFromOtherVC()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.userDetailsVC!.dismiss(animated: true, completion: nil)
                    self.tabBarController?.selectedIndex = 1
                })
            }
        } else if self.chatVC != nil {
            self.dismiss(animated: true, completion: nil)
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
        } else { return }

    }
    
    @IBAction func blockForeverBtnWasPressed(_ sender: Any) {
        blockAction()
    }
    
    @IBAction func blockTemporarilyBtnWasPressed(_ sender: Any) {
        temporaryBlockAction()
    }
    
    @IBAction func flagUserBtnWasPressed(_ sender: Any) {
        // present flagVC to get reason, then do flagUserAction()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let flagVC = storyboard.instantiateViewController(withIdentifier: "FlagVC") as! FlagVC
        flagVC.username = self.username!
        flagVC.blockOptionsVC = self
        if self.userDetailsVC != nil {
            self.present(flagVC, animated: true, completion: nil)
        } else if self.chatVC != nil {
            self.present(flagVC, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    


}
