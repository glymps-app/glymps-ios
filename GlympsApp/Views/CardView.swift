//
//  CardView.swift
//  Glymps
//
//  Created by James B Morris on 4/30/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import SDWebImage

protocol MoreInfoDelegate: class {
    func goToMoreInfo(userId: String, cardView: CardView)
}

// A card in the "card deck" that displays each User's information
class CardView: UIView {
    
    var imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
    
    var informationLabel = UILabel()
    
    var images: [String]?
    
    var userId: String?
    
    var stackView: UIStackView?
    
    var moreInfoButton: UIButton?
    
    var messageUserButton: UIButton?
    
    var cycleLeftButton: UIButton?
    
    var cycleRightButton: UIButton?
    
    weak var moreInfoDelegate: MoreInfoDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // round image
        layer.cornerRadius = 15
        clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.fillSuperview()
        
        // layout label
        addSubview(informationLabel)
        informationLabel.numberOfLines = 0
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        informationLabel.text = ""
        informationLabel.textColor = .white
        informationLabel.layer.zPosition = 1

        // add tap gesture to cycle through profile images
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)

    }
    
    var imageIndex = 0
    
    // cycle through profile images, determines whether to cycle forward or backward bassd on touch location, and then setup image accordingly
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        
        let tapLocation = gesture.location(in: imageView)
        let shouldAdvanceNextPhoto = (tapLocation.x > ((frame.width / 2) + 120)) && (tapLocation.y < moreInfoButton!.frame.origin.y - 10) && (tapLocation.y > (messageUserButton?.frame.origin.y)! + 50) ? true : false
        
        if shouldAdvanceNextPhoto {
            imageIndex = min(imageIndex + 1, images!.count - 1)
            
            if (imageIndex == 0) && (images!.count > 1) {
                cycleLeftButton?.isHidden = true
                cycleLeftButton?.isEnabled = false
                cycleRightButton?.isHidden = false
                cycleRightButton?.isEnabled = true
            } else if (imageIndex == 1) && (images!.count > 2) {
                cycleLeftButton?.isHidden = false
                cycleLeftButton?.isEnabled = true
                cycleRightButton?.isHidden = false
                cycleRightButton?.isEnabled = true
            } else if (imageIndex == 1) && (images!.count == 2){
                cycleLeftButton?.isHidden = false
                cycleLeftButton?.isEnabled = true
                cycleRightButton?.isHidden = true
                cycleRightButton?.isEnabled = false
            } else if (imageIndex == 2) && (images!.count > 2){
                cycleLeftButton?.isHidden = false
                cycleLeftButton?.isEnabled = true
                cycleRightButton?.isHidden = true
                cycleRightButton?.isEnabled = false
            }
        } else if (tapLocation.x < ((frame.width / 2) - 120)) && (tapLocation.y < moreInfoButton!.frame.origin.y - 10) && (tapLocation.y > (messageUserButton?.frame.origin.y)! + 50) {
            imageIndex = max(0, imageIndex - 1)
            
            if (imageIndex == 0) && (images!.count > 1) {
                cycleLeftButton?.isHidden = true
                cycleLeftButton?.isEnabled = false
                cycleRightButton?.isHidden = false
                cycleRightButton?.isEnabled = true
            } else if (imageIndex == 1) && (images!.count > 2) {
                cycleLeftButton?.isHidden = false
                cycleLeftButton?.isEnabled = true
                cycleRightButton?.isHidden = false
                cycleRightButton?.isEnabled = true
            } else if (imageIndex == 1) && (images!.count == 2){
                cycleLeftButton?.isHidden = false
                cycleLeftButton?.isEnabled = true
                cycleRightButton?.isHidden = true
                cycleRightButton?.isEnabled = false
            } else if (imageIndex == 2) && (images!.count > 2){
                cycleLeftButton?.isHidden = false
                cycleLeftButton?.isEnabled = true
                cycleRightButton?.isHidden = true
                cycleRightButton?.isEnabled = false
            }
        } else if (tapLocation.y < moreInfoButton!.frame.origin.y - 10) && (tapLocation.y > (messageUserButton?.frame.origin.y)! + 50) {
            moreInfoDelegate?.goToMoreInfo(userId: self.userId ?? "", cardView: self)
        }
        
        let imageUrls = images![imageIndex]
        
        let photoUrl = URL(string: imageUrls)
        imageView.sd_setImage(with: photoUrl)
        
        self.subviews.forEach { (view) in
            let sv = stackView
            if view == sv {
                sv?.arrangedSubviews.forEach({ (v) in
                    v.backgroundColor = UIColor(white: 0, alpha: 0.1)
                })
                sv!.arrangedSubviews[imageIndex].backgroundColor = .white
            }
        }
    }
    
    // default view encoder
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

}
