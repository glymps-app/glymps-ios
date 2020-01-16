//
//  ProfileVC.swift
//  Glymps
//
//  Created by James B Morris on 4/29/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// profile screen for user to go to edit profile, edit settings, buy coins, or become a Glymps Premium User
class ProfileVC: UIViewController {
    
    @IBOutlet weak var backToDeckBtn: UIButton!
    
    @IBOutlet weak var shareGlympsBtn: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var editProfileBtn: UIButton!
    
    @IBOutlet weak var settingsBtn: UIButton!
    
    @IBOutlet weak var activatePremiumBtn: UIButton!
    
    @IBOutlet weak var coinsView: UIView!
    
    @IBOutlet weak var coinAnimateView: UIView!
    
    @IBOutlet weak var coinsViewLabel: UILabel!
    
    let bottomNavBar = BottomNavigationStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(bottomNavBar)
        bottomNavBar.heightAnchor.constraint(equalToConstant: 70).isActive = true
        bottomNavBar.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        bottomNavBar.settingsButton.tintColor = #colorLiteral(red: 0, green: 0.7123068571, blue: 1, alpha: 1)
        bottomNavBar.glympsImage.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        bottomNavBar.messagesButton.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        self.coinsView.layer.zPosition = 10
        self.coinsViewLabel.layer.zPosition = 15
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCoins))
        coinAnimateView.addGestureRecognizer(tapGesture)

        editProfileBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        editProfileBtn.layer.borderWidth = 1
        settingsBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        settingsBtn.layer.borderWidth = 1
        
        greetingLabel.text = ""
        coinsViewLabel.text = ""
        setupUI()
        
        bottomNavBar.glympsImage.addTarget(self, action: #selector(handleDeck), for: .touchUpInside)
        bottomNavBar.messagesButton.addTarget(self, action: #selector(handleMessages), for: .touchUpInside)
    }
    
    // set up welcome message and current user profile image
    func setupUI() {
        API.User.observeCurrentUser { (user) in
            let profileImages = user.profileImages
            if let image1 = profileImages?[0], let photoUrl = URL(string: image1) {
                self.profileImageView.sd_setImage(with: photoUrl)
            } else {
                print("Could not load photo.")
            }
            self.greetingLabel.text = "Hello, \(user.name!)!"
            self.coinsViewLabel.text = "\(user.coins!)"
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
                UIView.setAnimationRepeatCount(3)
                self.coinAnimateView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.coinAnimateView.layoutIfNeeded()
                
                }, completion: {completion in
                    self.coinAnimateView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.coinAnimateView.layoutIfNeeded()
            })
        }
    }
    
    // go to main deck screen
    @objc func handleDeck() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let deckVC = storyboard.instantiateViewController(withIdentifier: "DeckVC")
        self.present(deckVC, animated: true, completion: nil)
    }
    
    // go to inbox
    @objc func handleMessages() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessagesVC") as! MessagesVC
        self.present(messagesVC, animated: true, completion: nil)
    }
    
    // go to view controller to buy more coins
    @objc func handleCoins() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let buyCoinsVC = storyboard.instantiateViewController(withIdentifier: "BuyCoinsVC")
        self.present(buyCoinsVC, animated: true, completion: nil)
    }
    
    // go back to "card deck"
    @IBAction func backToDeckBtnWasPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let deckVC = storyboard.instantiateViewController(withIdentifier: "DeckVC")
        self.present(deckVC, animated: true, completion: nil)
    }
    
    // share Glymps!
    @IBAction func shareGlympsBtnWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let shareGlympsVC = storyboard.instantiateViewController(withIdentifier: "ShareGlympsVC")
        self.present(shareGlympsVC, animated: true, completion: nil)
    }
    
    
    // go to edit profile
    @IBAction func editProfileBtnWasPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileVC")
        self.present(editProfileVC, animated: true, completion: nil)
    }
    
    // go to edit settings
    @IBAction func settingsBtnWasPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsVC")
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    // go become a Glymps Premium User
    @IBAction func activatePremiumBtnWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let activatePremiumVC = storyboard.instantiateViewController(withIdentifier: "ActivatePremiumVC")
        self.present(activatePremiumVC, animated: true, completion: nil)
    }
    

}
