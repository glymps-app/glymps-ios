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
    
    @IBOutlet weak var shareWithCodeBtn: UIButton!
    
    @IBOutlet weak var inviteContactBtn: UIButton!
    
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
                self.shareWithCodeBtn.setTitle(defaults.string(forKey: "hasSeenShare"), for: .normal)
            }
        } else {
            self.shareWithCodeBtn.setTitle(defaults.string(forKey: "hasSeenShare"), for: .normal)
        }
    }
    
    @IBAction func dismissBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func shareWithCodeBtnWasPressed(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [shareWithCodeBtn.titleLabel!.text!], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func inviteContactBtnWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contactsVC = storyboard.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsVC
        contactsVC.shareableLink = shareWithCodeBtn.titleLabel!.text!
        self.present(contactsVC, animated: true, completion: nil)
    }
    
    @IBAction func ambassadorBtnWasPressed(_ sender: Any) {
        // go to campus ambassador onboarding
    }
    
}
