//
//  OnboardDoneVC.swift
//  Glymps
//
//  Created by James B Morris on 5/7/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// screen to celebrate the onboarding of a new Glymps user!
class OnboardDoneVC: UIViewController {
    
    @IBOutlet weak var enterBtn: UIButton!
    
    var refUID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refUID = referringUser
        
        print("Referring User: \(refUID ?? ""). Press enter to reward them 3 coins...")
        
        enterBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        enterBtn.layer.borderWidth = 1
    }
    
    // enter the app and go to the "card deck"
    @IBAction func enterBtnWasPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()! as! DeckVC
        initial.currentUserReferredBy = refUID ?? ""
        self.present(initial, animated: true, completion: nil)
    }
    

}
