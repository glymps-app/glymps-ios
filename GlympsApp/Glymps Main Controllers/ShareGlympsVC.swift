//
//  ShareGlympsVC.swift
//  GlympsApp
//
//  Created by James B Morris on 9/29/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

class ShareGlympsVC: UIViewController {
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    @IBOutlet weak var shareWithFacebookBtn: UIButton!
    
    @IBOutlet weak var shareWithTwitterBtn: UIButton!
    
    @IBOutlet weak var shareWithEmailBtn: UIButton!
    
    @IBOutlet weak var shareWithSMSBtn: UIButton!
    
    @IBOutlet weak var personalCodeLabel: UILabel!
    
    @IBOutlet weak var ambassadorSignupBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCode()
    }
    
    func setupCode() {
        let defaults = UserDefaults.standard
        let hasSeenShare = defaults.bool(forKey: "hasSeenShare")
        if !hasSeenShare {
            API.User.observeCurrentUser { (user) in
                let codeSuffix = String(NSUUID().uuidString.prefix(5))
                let code = user.name! + codeSuffix
                defaults.set("\(code)", forKey: "hasSeenShare")
                self.personalCodeLabel.text = defaults.string(forKey: "hasSeenShare")
            }
        } else {
            self.personalCodeLabel.text = defaults.string(forKey: "hasSeenShare")
        }
    }
    
    @IBAction func dismissBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareWithFacebookBtnWasPressed(_ sender: Any) {
        
    }
    
    @IBAction func shareWithTwitterBtnWasPressed(_ sender: Any) {
        
    }
    
    @IBAction func shareWithEmailBtnWasPressed(_ sender: Any) {
        
    }
    
    @IBAction func shareWithSMSBtnWasPressed(_ sender: Any) {
        
    }
    
    @IBAction func ambassadorBtnWasPressed(_ sender: Any) {
        
    }
    
}
