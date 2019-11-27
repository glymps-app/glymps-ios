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
    
    @IBOutlet weak var logoutBtn: UIButton!
    
    @IBOutlet weak var deleteAccountBtn: UIButton!
    
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

    // setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.User.observeCurrentUser { (user) in
            if user.preferedGender == "Male" {
                self.maleBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
                self.maleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.maleBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
                self.maleBtn.layer.borderWidth = 1
            } else {
                self.maleBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
                self.maleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.maleBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
                self.maleBtn.layer.borderWidth = 1
            }
            
            if user.preferedGender == "Female" {
                self.femaleBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
                self.femaleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.femaleBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
                self.femaleBtn.layer.borderWidth = 1
            } else {
                self.femaleBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
                self.femaleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.femaleBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
                self.femaleBtn.layer.borderWidth = 1
            }
            
            if user.preferedGender == "Both" {
                self.bothBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
                self.bothBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.bothBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
                self.bothBtn.layer.borderWidth = 1
            } else {
                self.bothBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
                self.bothBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.bothBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
                self.bothBtn.layer.borderWidth = 1
            }
            
            self.rangeSlider.lowerValue = Double(user.minAge!)
            self.rangeSlider.upperValue = Double(user.maxAge!)
            
        }
        
        logoutBtn.setTitleColor(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1), for: .normal)
        logoutBtn.layer.borderColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        logoutBtn.layer.borderWidth = 1
        
        deleteAccountBtn.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
        deleteAccountBtn.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        deleteAccountBtn.layer.borderWidth = 1
        
    }

    // go back to main profile screen
    @IBAction func backBtnWasPressed(_ sender: Any) {
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
    
    // setup UI if male selected
    @IBAction func maleBtnWasPressed(_ sender: Any) {
        maleBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
        maleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        maleBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        maleBtn.layer.borderWidth = 1
        femaleBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        femaleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        femaleBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        bothBtn.layer.borderWidth = 1
        bothBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        bothBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        bothBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        bothBtn.layer.borderWidth = 1
        
        if chosenGender.isEmpty == true {
            chosenGender.append((maleBtn.titleLabel?.text!.capitalized)!)
        } else {
            chosenGender.removeAll()
            chosenGender.append((maleBtn.titleLabel?.text!.capitalized)!)
        }
    }
    
    // setup UI if female selected
    @IBAction func femaleBtnWasPressed(_ sender: Any) {
        femaleBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
        femaleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        femaleBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        femaleBtn.layer.borderWidth = 1
        maleBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        maleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        maleBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        maleBtn.layer.borderWidth = 1
        bothBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        bothBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        bothBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        bothBtn.layer.borderWidth = 1
        
        if chosenGender.isEmpty == true {
            chosenGender.append((femaleBtn.titleLabel?.text!.capitalized)!)
        } else {
            chosenGender.removeAll()
            chosenGender.append((femaleBtn.titleLabel?.text!.capitalized)!)
        }
    }
    
    // setup UI if both selected
    @IBAction func bothBtnWasPressed(_ sender: Any) {
        bothBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
        bothBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        bothBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        bothBtn.layer.borderWidth = 1
        femaleBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        femaleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        femaleBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        femaleBtn.layer.borderWidth = 1
        maleBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        maleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        maleBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        maleBtn.layer.borderWidth = 1
        
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
        
        genderToQuery = chosenGender.joined(separator: "")
        
        let minAge = Int(rangeSlider.lowerValue)
        let maxAge = Int(rangeSlider.upperValue)
    
        AuthService.saveSettings(minAge: minAge, maxAge: maxAge, preferedGender: genderToQuery) {
            hud.textLabel.text = "All done! \u{1F389}"
            hud.dismiss(afterDelay: 4.0)
        }
        
    }
    
    // authenticate and logout current user
    @IBAction func logoutBtnWasPressed(_ sender: Any) {
        // logout user
        
        let hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = "Logging you out..."
        hud.show(in: view)
        
        AuthService.logout(onSuccess: {
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            self.present(loginVC, animated: true, completion: nil)
            
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
                
                
                hud.textLabel.text = "Done."
                hud.dismiss(afterDelay: 4.0)
                
                let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
                self.present(loginVC, animated: true, completion: nil)
            }
        }
    }
    
    
    
}