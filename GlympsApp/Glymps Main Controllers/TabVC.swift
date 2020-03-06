//
//  TabVC.swift
//  GlympsApp
//
//  Created by James B Morris on 2/22/20.
//  Copyright © 2020 James B Morris. All rights reserved.
//

import UIKit

class TabVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectedIndex = 1
    }

}
