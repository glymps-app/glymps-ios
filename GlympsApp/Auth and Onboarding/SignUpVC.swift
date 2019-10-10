//
//  SignUpVC.swift
//  Glymps
//
//  Created by James B Morris on 5/6/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// view controller to initiate sign-up of new Glymps user!
class SignUpVC: UIViewController {
    
    @IBOutlet weak var startOnboardBtn: UIButton!
    
    @IBOutlet weak var cancelOnboardBtn: UIButton!
    
    @IBOutlet weak var toTermsOfServiceBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

       startOnboardBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        startOnboardBtn.layer.borderWidth = 1
        startOnboardBtn.layer.cornerRadius = 28
        
        cancelOnboardBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        cancelOnboardBtn.layer.borderWidth = 1
        cancelOnboardBtn.layer.cornerRadius = 28
    }
    
    // move to next view controller to begin onboarding
    @IBAction func startOnboardBtnWasPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let emailVC = storyboard.instantiateViewController(withIdentifier: "EmailVC")
        self.present(emailVC, animated: true, completion: nil)
    }
    
    // sign-up later :(
    @IBAction func cancelOnboardBtnWasPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        self.present(loginVC, animated: true, completion: nil)
    }
    
    // check out Glymps's official terms of service that is agreed upon already
    @IBAction func toTermsOfServiceBtnWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let termsOfServiceVC = storyboard.instantiateViewController(withIdentifier: "TermsOfServiceVC")
        self.present(termsOfServiceVC, animated: true, completion: nil)
    }
    
    


}
