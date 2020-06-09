//
//  SexPreferenceVC.swift
//  GlympsApp
//
//  Created by James B Morris on 5/2/20.
//  Copyright © 2020 James B Morris. All rights reserved.
//

import UIKit

class SexPreferenceVC: UIViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var menBtn: UIButton!
    
    @IBOutlet weak var womenBtn: UIButton!
    
    @IBOutlet weak var bothBtn: UIButton!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var userEmail = ""
    var userPassword = ""
    var userName = ""
    var userBio = ""
    var userProfession = ""
    var userCompany = ""
    var userAge = Int()
    var userGender = ""
    var chosenGenderPreference = ["Male"] {
        willSet {
            if self.chosenGenderPreference.isEmpty == true {
                nextBtn.isEnabled = false
            } else {
                nextBtn.isEnabled = true
            }
        }
        didSet {
            if self.chosenGenderPreference.isEmpty == true {
                nextBtn.isEnabled = false
            } else {
                nextBtn.isEnabled = true
            }

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nextBtn.isEnabled = true
        nextBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
        nextBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        nextBtn.layer.borderWidth = 1
        
        womenBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        womenBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        womenBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        womenBtn.layer.borderWidth = 1
        
        bothBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        bothBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        bothBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        bothBtn.layer.borderWidth = 1
    }
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func menBtnWasPressed(_ sender: Any) {
        menBtn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        menBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        womenBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        womenBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        womenBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        womenBtn.layer.borderWidth = 1
        bothBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        bothBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        bothBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        bothBtn.layer.borderWidth = 1
        
        if chosenGenderPreference.isEmpty == true {
            chosenGenderPreference.append("Male")
        } else {
            chosenGenderPreference.removeAll()
            chosenGenderPreference.append("Male")
        }
        
        if nextBtn.isEnabled == true {
            nextBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
            nextBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
            nextBtn.layer.borderWidth = 1
        } else {
            nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
            nextBtn.layer.borderWidth = 1
        }
    }
    
    @IBAction func womenBtnWasPressed(_ sender: Any) {
        womenBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        womenBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        menBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        menBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        menBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        menBtn.layer.borderWidth = 1
        bothBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        bothBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        bothBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        bothBtn.layer.borderWidth = 1
        
        if chosenGenderPreference.isEmpty == true {
            chosenGenderPreference.append("Female")
        } else {
            chosenGenderPreference.removeAll()
            chosenGenderPreference.append("Female")
        }
        
        if nextBtn.isEnabled == true {
            nextBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
            nextBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
            nextBtn.layer.borderWidth = 1
        } else {
            nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
            nextBtn.layer.borderWidth = 1
        }
    }
    
    @IBAction func bothBtnWasPressed(_ sender: Any) {
        bothBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        bothBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        menBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        menBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        menBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        menBtn.layer.borderWidth = 1
        womenBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        womenBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        womenBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        womenBtn.layer.borderWidth = 1
        
        if chosenGenderPreference.isEmpty == true {
            chosenGenderPreference.append("Both")
        } else {
            chosenGenderPreference.removeAll()
            chosenGenderPreference.append("Both")
        }
        
        if nextBtn.isEnabled == true {
            nextBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
            nextBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
            nextBtn.layer.borderWidth = 1
        } else {
            nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
            nextBtn.layer.borderWidth = 1
        }
    }
    
    @IBAction func nextBtnWasPressed(_ sender: Any) {
        if !chosenGenderPreference.isEmpty {
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let profileImageVC = storyboard.instantiateViewController(withIdentifier: "ProfileImageVC") as! ProfileImageVC
            profileImageVC.userEmail = userEmail
            profileImageVC.userPassword = userPassword
            profileImageVC.userName = userName
            profileImageVC.userBio = userBio
            profileImageVC.userProfession = userProfession
            profileImageVC.userCompany = userCompany
            profileImageVC.userAge = userAge
            profileImageVC.userGender = userGender
            profileImageVC.userGenderPreference = chosenGenderPreference.joined(separator: "")
            self.navigationController?.pushViewController(profileImageVC, animated: true)
        }
    }
    

}
