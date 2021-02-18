//
//  SettingsVC.swift
//  GlympsApp
//
//  Created by James B Morris on 6/27/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import JGProgressHUD
import SwiftRangeSlider
import Amplitude_iOS

// screen for user to update their settings
class SettingsVC: UITableViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var maleBtn: UIButton!
    
    @IBOutlet weak var femaleBtn: UIButton!
    
    @IBOutlet weak var bothBtn: UIButton!
    
    @IBOutlet weak var rangeSlider: RangeSlider!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var ghostModeBtn: UIButton!
    
    @IBOutlet weak var logoutBtn: UIButton!
    
    @IBOutlet weak var deleteAccountBtn: UIButton!
    
    @IBOutlet weak var tosPrivacyBtn: UIButton!
    
    var genderToQuery = ""
    
    var chosenGender = ["Male"] {
        willSet {
            if self.chosenGender.isEmpty == true {
                saveBtn.isEnabled = false
            } else {
                saveBtn.isEnabled = true
            }
        }
        didSet {
            if self.chosenGender.isEmpty == true {
                saveBtn.isEnabled = false
            } else {
                saveBtn.isEnabled = true
            }
            
        }
    }

    func selectButton(_ button: UIButton) {
        for button2 in [maleBtn!, femaleBtn!, bothBtn!] {
            update(button2, toSelected: button === button2)
        }
    }
    func update(_ button: UIButton, toSelected isSelected: Bool) {
        if isSelected {
            button.setTitleColor(#colorLiteral(red: 0.54, green: 0.75, blue: 0.86, alpha: 1), for: .normal)
            button.backgroundColor = .white
            button.layer.borderColor = #colorLiteral(red: 0.54, green: 0.75, blue: 0.86, alpha: 1)
            button.layer.borderWidth = 2.0
        } else {
            button.setTitleColor(#colorLiteral(red: 0.6, green: 0.682, blue: 0.733, alpha: 1), for: .normal)
            button.backgroundColor = .white
            button.layer.borderColor = #colorLiteral(red: 0.6, green: 0.682, blue: 0.733, alpha: 1)
            button.layer.borderWidth = 1.0
        }
    }

    // setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logAmplitudeSettingsViewedEvent()
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.saveBtn.setTitle("SAVE", for: .normal)
        
        API.Inbox.isInGhostMode { (bool) in
            if bool == true {
                self.ghostModeBtn.setTitle("EXIT GHOST MODE", for: .normal)
            } else if bool == false {
                self.ghostModeBtn.setTitle("ENTER GHOST MODE", for: .normal)
            }
        }
        
        API.User.observeCurrentUser { [weak self] (user) in
            guard let self = self else { return }
            self.update(self.maleBtn, toSelected: user.preferedGender == "Male")
            self.update(self.femaleBtn, toSelected: user.preferedGender == "Female")
            self.update(self.bothBtn, toSelected: user.preferedGender == "Both")
            
            self.rangeSlider.lowerValue = Double(user.minAge!)
            self.rangeSlider.upperValue = Double(user.maxAge!)
            
        }
        
        logoutBtn.setTitleColor(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1), for: .normal)
        logoutBtn.layer.borderColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        logoutBtn.layer.borderWidth = 1
        
        ghostModeBtn.setTitleColor(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1), for: .normal)
        ghostModeBtn.layer.borderColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        ghostModeBtn.layer.borderWidth = 1
        
        deleteAccountBtn.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
        deleteAccountBtn.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        deleteAccountBtn.layer.borderWidth = 1
        
    }

    // go back to main profile screen
    @IBAction func backBtnWasPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // setup UI if male selected
    @IBAction func maleBtnWasPressed(_ sender: Any) {
        selectButton(maleBtn)
        
        if chosenGender.isEmpty == true {
            chosenGender.append((maleBtn.titleLabel?.text!.capitalized)!)
        } else {
            chosenGender.removeAll()
            chosenGender.append((maleBtn.titleLabel?.text!.capitalized)!)
        }
    }
    
    // setup UI if female selected
    @IBAction func femaleBtnWasPressed(_ sender: Any) {
        selectButton(femaleBtn)
        
        if chosenGender.isEmpty == true {
            chosenGender.append((femaleBtn.titleLabel?.text!.capitalized)!)
        } else {
            chosenGender.removeAll()
            chosenGender.append((femaleBtn.titleLabel?.text!.capitalized)!)
        }
    }
    
    // setup UI if both selected
    @IBAction func bothBtnWasPressed(_ sender: Any) {
        selectButton(bothBtn)
        
        if chosenGender.isEmpty == true {
            chosenGender.append((bothBtn.titleLabel?.text!.capitalized)!)
        } else {
            chosenGender.removeAll()
            chosenGender.append((bothBtn.titleLabel?.text!.capitalized)!)
        }
    }
    
    // save user settings
    @IBAction func saveBtnWasPressed(_ sender: Any) {
        self.logAmplitudeSettingsChangedEvent()
        // save settings to Firebase
        let hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = "Saving your settings..."
        hud.show(in: view)
        self.saveBtn.setTitle("SAVING...", for: .normal)
        
        genderToQuery = chosenGender.joined(separator: "")
        
        let minAge = Int(rangeSlider.lowerValue)
        let maxAge = Int(rangeSlider.upperValue)
    
        AuthService.saveSettings(minAge: minAge, maxAge: maxAge, preferedGender: genderToQuery) {
            hud.textLabel.text = "All done! \u{1F389}"
            hud.dismiss(afterDelay: 4.0)
            self.saveBtn.setTitle("SAVED!", for: .normal)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.saveBtn.setTitle("SAVE", for: .normal)
            }
        }
    }
    
    // enter and exit "Ghost Mode"
    @IBAction func ghostModeBtnWasPressed(_ sender: Any) {
        let hud = JGProgressHUD(style: .extraLight)
        
        if ghostModeBtn.titleLabel?.text == "ENTER GHOST MODE" {
            self.logAmplitudeGhostModeEnabledEvent()
            hud.textLabel.text = "Entering Ghost Mode..."
            hud.show(in: view)
            API.Inbox.goIntoGhostMode {
                self.ghostModeBtn.setTitle("EXIT GHOST MODE", for: .normal)
            }
            hud.textLabel.text = "You're in Ghost Mode. \u{1F47B}"
            hud.dismiss(afterDelay: 2.0)
        } else if ghostModeBtn.titleLabel?.text == "EXIT GHOST MODE" {
            self.logAmplitudeGhostModeDisabledEvent()
            hud.textLabel.text = "Exiting Ghost Mode..."
            hud.show(in: view)
            API.Inbox.goOutOfGhostMode {
            }
            self.ghostModeBtn.setTitle("ENTER GHOST MODE", for: .normal)
            hud.textLabel.text = "You're out of Ghost Mode. \u{1F60A}"
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    // authenticate and logout current user
    @IBAction func logoutBtnWasPressed(_ sender: Any) {
        // logout user
        
        let hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = "Logging you out..."
        hud.show(in: view)
        
        beamsClient.clearAllState {
          print("Successfully cleared all state")
        }
        
        self.logAmplitudeSignoutEvent()
        
        AuthService.logout(onSuccess: {
            
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(loginVC, animated: true)
            
            hud.textLabel.text = "All done! \u{1F389}"
            hud.dismiss(afterDelay: 4.0)
        }) {
            hud.textLabel.text = "Whoops, something's not right. \u{1F615}"
            hud.dismiss(afterDelay: 4.0)
        }
    }
    
    @IBAction func deleteAccountBtnWasPressed(_ sender: Any) {
        // delete user account :(
        
        self.logAmplitudeAccountDeletionEvent()
        
        let hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = "Saying goodbye :( ..."
        hud.show(in: view)
        
        // delete user from Auth
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if error != nil {
                // An error happened.
                hud.textLabel.text = "Whoops, something went wrong."
                hud.dismiss(afterDelay: 4.0)
            } else {
                // Account deleted.
            Database.database().reference().child("users").child(API.User.CURRENT_USER!.uid).removeValue()
                
                self.deletePusherUser(userToDelete: API.User.CURRENT_USER!.uid)
                
                hud.textLabel.text = "Done."
                hud.dismiss(afterDelay: 4.0)
                
                let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
    }
    
    @IBAction func tosPrivacyBtnWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let termsOfServiceVC = storyboard.instantiateViewController(withIdentifier: "TermsOfServiceVC")
        self.present(termsOfServiceVC, animated: true, completion: nil)
    }
    
    func logAmplitudeSignoutEvent() {
        API.User.observeCurrentUser { (user) in
            var signOutEventProperties: [AnyHashable : Any] = [:]
            signOutEventProperties.updateValue(user.email as Any, forKey: "Email")
            signOutEventProperties.updateValue(user.age as Any, forKey: "Age")
            signOutEventProperties.updateValue(user.profession as Any, forKey: "Profession")
            signOutEventProperties.updateValue(user.company as Any, forKey: "Company")
            signOutEventProperties.updateValue(user.name as Any, forKey: "Name")
            signOutEventProperties.updateValue(user.gender as Any, forKey: "Gender")
            signOutEventProperties.updateValue(user.id as Any, forKey: "User ID")
            signOutEventProperties.updateValue(user.coins as Any, forKey: "Number of Glymps Coins")
            signOutEventProperties.updateValue(user.isPremium as Any, forKey: "Subscription Status")
            signOutEventProperties.updateValue(user.minAge as Any, forKey: "Minimum Preferred Age")
            signOutEventProperties.updateValue(user.maxAge as Any, forKey: "Maximum Preferred Age")
            signOutEventProperties.updateValue(user.preferedGender as Any, forKey: "Preferred Gender")
            Amplitude.instance().logEvent("Sign Out", withEventProperties: signOutEventProperties)
        }
    }
    
    func logAmplitudeAccountDeletionEvent() {
        API.User.observeCurrentUser { (user) in
            var accountDeletionEventProperties: [AnyHashable : Any] = [:]
            accountDeletionEventProperties.updateValue(user.email as Any, forKey: "Email")
            accountDeletionEventProperties.updateValue(user.age as Any, forKey: "Age")
            accountDeletionEventProperties.updateValue(user.profession as Any, forKey: "Profession")
            accountDeletionEventProperties.updateValue(user.company as Any, forKey: "Company")
            accountDeletionEventProperties.updateValue(user.name as Any, forKey: "Name")
            accountDeletionEventProperties.updateValue(user.gender as Any, forKey: "Gender")
            accountDeletionEventProperties.updateValue(user.id as Any, forKey: "User ID")
            accountDeletionEventProperties.updateValue(user.coins as Any, forKey: "Number of Glymps Coins")
            accountDeletionEventProperties.updateValue(user.isPremium as Any, forKey: "Subscription Status")
            accountDeletionEventProperties.updateValue(user.minAge as Any, forKey: "Minimum Preferred Age")
            accountDeletionEventProperties.updateValue(user.maxAge as Any, forKey: "Maximum Preferred Age")
            accountDeletionEventProperties.updateValue(user.preferedGender as Any, forKey: "Preferred Gender")
            Amplitude.instance().logEvent("Account Deletion", withEventProperties: accountDeletionEventProperties)
        }
    }
    
    func logAmplitudeSettingsChangedEvent() {
        API.User.observeCurrentUser { (user) in
            var settingsChangedEventProperties: [AnyHashable : Any] = [:]
            settingsChangedEventProperties.updateValue(user.email as Any, forKey: "Email")
            settingsChangedEventProperties.updateValue(user.age as Any, forKey: "Age")
            settingsChangedEventProperties.updateValue(user.profession as Any, forKey: "Profession")
            settingsChangedEventProperties.updateValue(user.company as Any, forKey: "Company")
            settingsChangedEventProperties.updateValue(user.name as Any, forKey: "Name")
            settingsChangedEventProperties.updateValue(user.gender as Any, forKey: "Gender")
            settingsChangedEventProperties.updateValue(user.id as Any, forKey: "User ID")
            settingsChangedEventProperties.updateValue(user.coins as Any, forKey: "Number of Glymps Coins")
            settingsChangedEventProperties.updateValue(user.isPremium as Any, forKey: "Subscription Status")
            settingsChangedEventProperties.updateValue(user.minAge as Any, forKey: "Minimum Preferred Age")
            settingsChangedEventProperties.updateValue(user.maxAge as Any, forKey: "Maximum Preferred Age")
            settingsChangedEventProperties.updateValue(user.preferedGender as Any, forKey: "Preferred Gender")
            Amplitude.instance().logEvent("Settings Changed", withEventProperties: settingsChangedEventProperties)
        }
    }
    
    func logAmplitudeGhostModeEnabledEvent() {
        API.User.observeCurrentUser { (user) in
            var ghostModeEnabledEventProperties: [AnyHashable : Any] = [:]
            ghostModeEnabledEventProperties.updateValue(user.email as Any, forKey: "Email")
            ghostModeEnabledEventProperties.updateValue(user.age as Any, forKey: "Age")
            ghostModeEnabledEventProperties.updateValue(user.profession as Any, forKey: "Profession")
            ghostModeEnabledEventProperties.updateValue(user.company as Any, forKey: "Company")
            ghostModeEnabledEventProperties.updateValue(user.name as Any, forKey: "Name")
            ghostModeEnabledEventProperties.updateValue(user.gender as Any, forKey: "Gender")
            ghostModeEnabledEventProperties.updateValue(user.id as Any, forKey: "User ID")
            ghostModeEnabledEventProperties.updateValue(user.coins as Any, forKey: "Number of Glymps Coins")
            ghostModeEnabledEventProperties.updateValue(user.isPremium as Any, forKey: "Subscription Status")
            ghostModeEnabledEventProperties.updateValue(user.minAge as Any, forKey: "Minimum Preferred Age")
            ghostModeEnabledEventProperties.updateValue(user.maxAge as Any, forKey: "Maximum Preferred Age")
            ghostModeEnabledEventProperties.updateValue(user.preferedGender as Any, forKey: "Preferred Gender")
            Amplitude.instance().logEvent("Ghost Mode Enabled", withEventProperties: ghostModeEnabledEventProperties)
        }
    }
    
    func logAmplitudeGhostModeDisabledEvent() {
        API.User.observeCurrentUser { (user) in
            var ghostModeDisabledEventProperties: [AnyHashable : Any] = [:]
            ghostModeDisabledEventProperties.updateValue(user.email as Any, forKey: "Email")
            ghostModeDisabledEventProperties.updateValue(user.age as Any, forKey: "Age")
            ghostModeDisabledEventProperties.updateValue(user.profession as Any, forKey: "Profession")
            ghostModeDisabledEventProperties.updateValue(user.company as Any, forKey: "Company")
            ghostModeDisabledEventProperties.updateValue(user.name as Any, forKey: "Name")
            ghostModeDisabledEventProperties.updateValue(user.gender as Any, forKey: "Gender")
            ghostModeDisabledEventProperties.updateValue(user.id as Any, forKey: "User ID")
            ghostModeDisabledEventProperties.updateValue(user.coins as Any, forKey: "Number of Glymps Coins")
            ghostModeDisabledEventProperties.updateValue(user.isPremium as Any, forKey: "Subscription Status")
            ghostModeDisabledEventProperties.updateValue(user.minAge as Any, forKey: "Minimum Preferred Age")
            ghostModeDisabledEventProperties.updateValue(user.maxAge as Any, forKey: "Maximum Preferred Age")
            ghostModeDisabledEventProperties.updateValue(user.preferedGender as Any, forKey: "Preferred Gender")
            Amplitude.instance().logEvent("Ghost Mode Disabled", withEventProperties: ghostModeDisabledEventProperties)
        }
    }
    
    func logAmplitudeSettingsViewedEvent() {
        Amplitude.instance().logEvent("Settings Viewed")
    }
    
    
    // delete user from Pusher
    func deletePusherUser(userToDelete: String) {
        let notificationsURL = URL(string: "https://glymps-pusher-notifications.herokuapp.com/pusher/delete-user")!
        var request = URLRequest(url: notificationsURL)
        request.httpBody = "user_id=\(userToDelete)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            if (error != nil) {
                print("Error: \(error?.localizedDescription ?? "")")
            } else {
                print("Successfully deleted Pusher user.")
            }
            }.resume()
    }
    
    
    
}
