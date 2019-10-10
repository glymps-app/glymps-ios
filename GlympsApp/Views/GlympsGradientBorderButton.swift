//
//  GlympsGradientBorderButton.swift
//  GlympsApp
//
//  Created by James B Morris on 8/12/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// A UIButton that has a gradient view masked over its border
class GlympsGradientBorderButton: UIButton {

    // layout function to set up gradient view and colors for the UI
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let gradientLayer = CAGradientLayer()
        let leftColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        let rightColor = #colorLiteral(red: 0.1254753624, green: 0.8749372697, blue: 1, alpha: 0.4017818921)
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let maskLayer = CAShapeLayer()
        let maskPath = CGMutablePath()
        maskPath.addPath(UIBezierPath(roundedRect: rect, cornerRadius: 30).cgPath)
        
        maskPath.addPath(UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: 30).cgPath)
        
        maskLayer.path = maskPath
        maskLayer.fillRule = .evenOdd
        
        gradientLayer.mask = maskLayer
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = rect
    }

}
