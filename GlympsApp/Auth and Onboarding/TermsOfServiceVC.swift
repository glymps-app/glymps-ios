//
//  TermsOfServiceVC.swift
//  Glymps
//
//  Created by James B Morris on 5/6/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// view controller that display's Glymps, Inc.'s official terms of service for Glymps iOS. This is automatically agreed to by every user of Glymps.
class TermsOfServiceVC: UIViewController {
    
    @IBOutlet weak var closeBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    // close terms of service screen
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    


}
