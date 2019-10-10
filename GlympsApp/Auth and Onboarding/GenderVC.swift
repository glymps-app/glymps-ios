//
//  GenderVC.swift
//  Glymps
//
//  Created by James B Morris on 5/7/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// view controller to set up new user gender during onboarding
class GenderVC: UIViewController {
    
    @IBOutlet weak var maleBtn: UIButton!
    
    @IBOutlet weak var femaleBtn: UIButton!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var userEmail = ""
    var userPassword = ""
    var userName = ""
    var userAge = Int()
    var chosenGender = ["Male"] {
        willSet {
            if self.chosenGender.isEmpty == true {
                nextBtn.isEnabled = false
            } else {
                nextBtn.isEnabled = true
            }
        }
        didSet {
            if self.chosenGender.isEmpty == true {
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
        
        femaleBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        femaleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        femaleBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        femaleBtn.layer.borderWidth = 1
    }
    
    // select male as gender and setup UI accordingly
    @IBAction func maleBtnWasPressed(_ sender: Any) {
        maleBtn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        maleBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        femaleBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        femaleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        femaleBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        femaleBtn.layer.borderWidth = 1
        
        if chosenGender.isEmpty == true {
            chosenGender.append((maleBtn.titleLabel?.text!.capitalized)!)
        } else {
            chosenGender.removeAll()
            chosenGender.append((maleBtn.titleLabel?.text!.capitalized)!)
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
    
    // select female as gender and setup UI accordingly
    @IBAction func femaleBtnWasPressed(_ sender: Any) {
        femaleBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        femaleBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        maleBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        maleBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        maleBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        maleBtn.layer.borderWidth = 1
        
        if chosenGender.isEmpty == true {
            chosenGender.append((femaleBtn.titleLabel?.text!.capitalized)!)
        } else {
            chosenGender.removeAll()
            chosenGender.append((femaleBtn.titleLabel?.text!.capitalized)!)
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
    
    // prep for segue to next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ProfileImageVC
        destination.userEmail = userEmail
        destination.userPassword = userPassword
        destination.userName = userName
        destination.userAge = userAge
        destination.userGender = chosenGender.joined(separator: "")
    }
    
    // move to next view controller
    @IBAction func nextBtnWasPressed(_ sender: Any) {
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        if !chosenGender.isEmpty {
            performSegue(withIdentifier: "genderToProfileImage", sender: self)
        }
    }
    
    
}
