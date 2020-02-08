//
//  MessagesVC.swift
//  GlympsApp
//
//  Created by James B Morris on 7/31/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import LBTATools

// inbox screen for new message requests, and recent conversations of matched users
class MessagesVC: UIViewController {
    
    @IBOutlet weak var backToDeckBtn: UIButton!
    
    @IBOutlet weak var navBar: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    let bottomNavBar = BottomNavigationStackView()
    
    var userId: String?
    
    var newMessages: [User] = []
    
    var matches: [User] = []
    
    var matchedMessages: [Message] = []
    
    var currentUsername: String?
    
    var currentUser: User?

    // setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCurrentUser()
        
        view.addSubview(bottomNavBar)
        bottomNavBar.heightAnchor.constraint(equalToConstant: 70).isActive = true
        bottomNavBar.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        bottomNavBar.messagesButton.tintColor = #colorLiteral(red: 0, green: 0.7123068571, blue: 1, alpha: 1)
        bottomNavBar.settingsButton.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        bottomNavBar.glympsImage.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        newMessages = []
        matches = []
        matchedMessages = []
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadNewMessages()
        loadMatches()
        
        navBar.setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        bottomNavBar.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomNavBar.glympsImage.addTarget(self, action: #selector(handleDeck), for: .touchUpInside)
        
    }
    
    // setup UI beforehand, go to chat if coming to this view after tapping message button in "card deck"
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            
//            if let id = self.userId {
//                let transition = CATransition()
//                transition.duration = 0.3
//                transition.type = CATransitionType.push
//                transition.subtype = CATransitionSubtype.fromRight
//                transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
//                self.view.window!.layer.add(transition, forKey: kCATransition)
//                
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
//                chatVC.userId = id
//                chatVC.messagesVC = self
//                self.present(chatVC, animated: true, completion: nil)
//                self.userId = nil
//            }
//        }
//    }
    
    // get current user
    func setupCurrentUser() {
        API.User.observeCurrentUser { (user) in
            self.currentUser = user
            self.currentUsername = user.name!
            print("Current user: \(self.currentUser!)")
        }
    }
    
    // go to main profile screen
    @objc func handleSettings() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC")
        self.present(profileVC, animated: true, completion: nil)
    }
    
    // go to main deck screen
    @objc func handleDeck() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let deckVC = storyboard.instantiateViewController(withIdentifier: "DeckVC")
        self.present(deckVC, animated: true, completion: nil)
    }
    
    func loadNewMessages() {
        
        // load new message requests
        
        API.Inbox.loadMessageRequests { (user) in
            if user.id != API.User.CURRENT_USER?.uid {
                
                self.newMessages.insert(user, at: 0)
            }
            self.collectionView.reloadData()
            print("Requests:", self.newMessages)
        }
    }
    
    func loadMatches() {
        
        // load matched users
        
        API.Inbox.loadMatches { (user) in
            if user.id != API.User.CURRENT_USER?.uid {
                
                self.matches.insert(user, at: 0)
            }
            self.tableView.reloadData()
            print("Matches:", self.matches)
        }
    } 

    // go back to "card deck"
    @IBAction func backToDeckBtnWasPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let deckVC = storyboard.instantiateViewController(withIdentifier: "DeckVC")
        self.present(deckVC, animated: true, completion: nil)
    }
    
    // go to chat screen
    func goToChat(userId: String) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.userId = userId
        chatVC.currentUsername = self.currentUsername
        chatVC.currentUser = self.currentUser
        chatVC.messagesVC = self
        self.present(chatVC, animated: true, completion: nil)
    }
    

}

// setup tableView for recent match conversations
extension MessagesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if matches.count == 0 {
            tableView.setEmptyView(title: "No matches yet.", message: "Visit that feed and find your special someone!", image: UIImage())
            tableView.separatorStyle = .none
        }
        else {
            tableView.separatorStyle = .singleLine
            tableView.restore()
        }
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchConversationCell", for: indexPath) as! MatchConversationCell
        cell.user = matches[indexPath.row]
        cell.configureCell(uid: matches[indexPath.row].id!)
        
        return cell
    }
    
    // go to chat when cell selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MatchConversationCell
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.messagesVC = self
        chatVC.cardView = cell.cardView
        chatVC.userId = cell.user?.id
        chatVC.currentUsername = self.currentUsername
        chatVC.currentUser = self.currentUser
        self.present(chatVC, animated: true, completion: nil)
    }
    
    // fixed cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    
}

// setup collectionView for recent message requests
extension MessagesVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if newMessages.count == 0 {
            collectionView.setEmptyView(title: "No new messages.", message: "Don't worry, somebody will definitely message you soon!", image: UIImage())
        }
        else {
            collectionView.restore()
        }
        return newMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewMessageCell", for: indexPath) as! NewMessageCell
        let newMessage = newMessages[indexPath.row]
        cell.user = newMessage
        
        return cell
    }
    
    // go to chat when cell selecteds
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! NewMessageCell
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
            
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.messagesVC = self
        chatVC.cardView = cell.cardView
        chatVC.userId = cell.user?.id
        chatVC.currentUsername = self.currentUsername
        chatVC.currentUser = self.currentUser
        self.present(chatVC, animated: true, completion: nil)
    }
}
