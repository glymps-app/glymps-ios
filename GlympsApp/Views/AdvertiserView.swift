//
//  AdvertiserView.swift
//  GlympsApp
//
//  Created by James B Morris on 7/16/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import SDWebImage
import SmaatoSDKCore
import SmaatoSDKNative

// A card in the "card deck" that displays an ad
class NativeAdCardView: UIView {
    
    var imageView = UIImageView(image: #imageLiteral(resourceName: "glymps-hbg"))

    var nameLabel = UILabel()

    var stackView: UIStackView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // round image
        layer.cornerRadius = 15
        clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        layer.borderColor = #colorLiteral(red: 0, green: 0.7123068571, blue: 1, alpha: 1)
        layer.borderWidth = 1
        backgroundColor = .black
        addSubview(imageView)
        imageView.fillSuperview()

        // layout label
        addSubview(nameLabel)
        nameLabel.numberOfLines = 0
        nameLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        nameLabel.text = ""
        nameLabel.textColor = #colorLiteral(red: 0.7909700138, green: 0.8583178344, blue: 1, alpha: 1)
        nameLabel.layer.zPosition = 1
        
    }
    
    // default view encoder
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
