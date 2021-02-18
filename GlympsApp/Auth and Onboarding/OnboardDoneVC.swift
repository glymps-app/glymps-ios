//
//  OnboardDoneVC.swift
//  Glymps
//
//  Created by James B Morris on 5/7/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import Amplitude_iOS

// screen to celebrate the onboarding of a new Glymps user!
class OnboardDoneVC: UIViewController {
    
    @IBOutlet weak var enterBtn: UIButton!
    
    var refUID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logAmplitudeOnboardingCompletedEvent()
        
        refUID = referringUser
        
        print("Referring User: \(refUID ?? ""). Press enter to reward them 3 coins...")
        
        enterBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        enterBtn.layer.borderWidth = 1
    }
    
    // enter the app and go to the "card deck"
    @IBAction func enterBtnWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()! as! TabVC
        let deckVC = initial.children[1].children[0] as! DeckVC
        deckVC.currentUserReferredBy = refUID ?? ""
        self.navigationController?.pushViewController(initial, animated: true)
    }
    
    func logAmplitudeOnboardingCompletedEvent() {
        Amplitude.instance().logEvent("Onboarding Completed")
    }
    

}
