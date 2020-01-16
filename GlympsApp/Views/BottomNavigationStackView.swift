//
//  BottomNavigationStackView.swift
//  Glymps
//
//  Created by James B Morris on 4/30/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// The bottom tab bar that allows the user to visit Messages and Profile
class BottomNavigationStackView: UIStackView {
    
    let settingsButton = UIButton(type: .system)
    let messagesButton = UIButton(type: .system)
    let glympsImage = UIButton(type: .system)

    // setup navigation content
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        settingsButton.setImage(#imageLiteral(resourceName: "top_left_profile").withRenderingMode(.alwaysTemplate), for: .normal)
        messagesButton.setImage(#imageLiteral(resourceName: "top_right_messages").withRenderingMode(.alwaysTemplate), for: .normal)
        glympsImage.setImage(#imageLiteral(resourceName: "glymps_logo").withRenderingMode(.alwaysTemplate), for: .normal)
        
        [settingsButton, UIView(), glympsImage, UIView(), messagesButton].forEach { (v) in
            addArrangedSubview(v)
        }
        
        distribution = .equalCentering
        
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 25, bottom: 0, right: 25)
        
    }
    
    // default view encoder
    required init(coder: NSCoder) {
        fatalError()
    }
    
    

}
