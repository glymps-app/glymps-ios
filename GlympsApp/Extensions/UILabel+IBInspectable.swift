//
//  UILabel+IBInspectable.swift
//  GlympsApp
//
//  Created by Charley Luckhardt on 6/17/20.
//  Copyright © 2020 James B Morris. All rights reserved.
//

import Foundation

@IBDesignable
extension UILabel {

    @IBInspectable var characterSpacing: CGFloat {
        get {
            guard let attributedText = attributedText else { return 1 }
            return attributedText.attribute(.kern, at: 0, effectiveRange: nil) as? CGFloat ?? 1
        }
        set {
            let attributedString = NSMutableAttributedString(string: text ?? "")

            attributedString.addAttribute(.kern, value: newValue, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }

    }
}
