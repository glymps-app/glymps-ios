//
//  ActivatePremiumVC.swift
//  GlympsApp
//
//  Created by James B Morris on 7/13/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import Purchases

// screen that displays advantages of upgrading to Glymps Premium
class ActivatePremiumVC: UIViewController {
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    @IBOutlet weak var activatePremiumBtn: UIButton!
    
    // app entitlements
    var entitlements: [String : Entitlement] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    // display popover that shows subscription options
    func displayUpsellScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let premiumVC = storyboard.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
        self.present(premiumVC, animated: true, completion: nil)
    }

    // go back to main profile screen
    @IBAction func dismissBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // display popover that shows subscription options
    @IBAction func activatePremiumBtnWasPressed(_ sender: Any) {
        
        displayUpsellScreen()
    }
    
}
