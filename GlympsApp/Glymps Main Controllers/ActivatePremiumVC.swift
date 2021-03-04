//
//  ActivatePremiumVC.swift
//  GlympsApp
//
//  Created by James B Morris on 7/13/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import Amplitude_iOS

// screen that displays advantages of upgrading to Glymps Premium
class ActivatePremiumVC: UIViewController {
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    @IBOutlet weak var activatePremiumBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.logAmplitudeActivatePremiumViewEvent()
    }
    
    // display popover that shows subscription options
    func displayUpsellScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let premiumVC = storyboard.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
        self.present(premiumVC, animated: true, completion: nil)
    }

    // go back to main profile screen
    @IBAction func dismissBtnWasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // display popover that shows subscription options
    @IBAction func activatePremiumBtnWasPressed(_ sender: Any) {
        self.logAmplitudePremiumPaywallDisplayedEvent()
        displayUpsellScreen()
    }
    
    func logAmplitudePremiumPaywallDisplayedEvent() {
        Amplitude.instance().logEvent("Premium Paywall Displayed")
    }
    
    func logAmplitudeActivatePremiumViewEvent() {
        Amplitude.instance().logEvent("Premium View")
    }
    
}
