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
    let glympsImage = UIImageView(image: #imageLiteral(resourceName: "glymps_logo"))

    // setup navigation content
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        glympsImage.contentMode = .scaleAspectFit
        
        settingsButton.setImage(#imageLiteral(resourceName: "top_left_profile").withRenderingMode(.alwaysOriginal), for: .normal)
        messagesButton.setImage(#imageLiteral(resourceName: "top_right_messages").withRenderingMode(.alwaysOriginal), for: .normal)
        glympsImage.image?.withRenderingMode(.alwaysOriginal)
        
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
