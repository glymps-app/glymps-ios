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
            hud.textLabel.text = "Entering Ghost Mode..."
            hud.show(in: view)
            API.Inbox.goIntoGhostMode {
                self.ghostModeBtn.setTitle("EXIT GHOST MODE", for: .normal)
            }
            hud.textLabel.text = "You're in Ghost Mode. \u{1F47B}"
            hud.dismiss(afterDelay: 2.0)
        } else if ghostModeBtn.titleLabel?.text == "EXIT GHOST MODE" {
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
