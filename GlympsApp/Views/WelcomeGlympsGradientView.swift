//
//  WelcomeGlympsGradientView.swift
//  Glymps
//
//  Created by James B Morris on 4/30/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
@IBDesignable

// The gradient view on the app's login screen
class WelcomeGlympsGradientView: UIView {
    
    // top gradient color
    @IBInspectable var topColor: UIColor = UIColor.white {
        didSet {
            // lays out topColor accordingly
            self.setNeedsLayout()
        }
    }
    
    // bottom gradient color
    @IBInspectable var bottomColor: UIColor = #colorLiteral(red: 0.09720204157, green: 0.7115947173, blue: 1, alpha: 1) {
        didSet {
            // lays out bottom color accordingly
            self.setNeedsLayout()
        }
    }
    
    // layout function to set up gradient view and colors for the UI
    override func layoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.3, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
