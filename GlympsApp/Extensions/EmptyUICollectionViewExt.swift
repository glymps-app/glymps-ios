//
//  EmptyUICollectionViewExt.swift
//  GlympsApp
//
//  Created by James B Morris on 7/31/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// display image and short message if a collectionView within Glymps is empty
extension UICollectionView {
    
    func setEmptyView(title: String, message: String, image: UIImage) {
        
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        let imageDisplayed = UIImageView()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        imageDisplayed.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(imageDisplayed)
        imageDisplayed.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        imageDisplayed.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 0).isActive = true
        imageDisplayed.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageDisplayed.heightAnchor.constraint(equalToConstant: 150).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        imageDisplayed.image = image
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        
        self.backgroundView = emptyView
        
    }
    
    func restore() {
        self.backgroundView = nil
    }
    
}
