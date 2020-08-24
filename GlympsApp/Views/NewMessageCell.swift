//
//  NewMessageCell.swift
//  GlympsApp
//
//  Created by James B Morris on 7/31/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// cell for displaying new message request in the inbox
class NewMessageCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    var cardView: CardView!
    
    // set requesting user
    var user: User? {
        didSet {
            usernameLabel.text = ""
            updateViews()
        }
    }
    
    // setup profile image and username within cell, and setup CardView to pass to chat controller so current user can view requesting user's details
    func updateViews() {
        
        if let photoUrlString = user?.profileImages?.first {
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl)
        }
        
        usernameLabel.text = user?.name
        
        self.isUserInteractionEnabled = true
        
        let gradientView = GlympsGradientView()
        let barsStackView = UIStackView()
        gradientView.layer.opacity = 0.5
        let cardView = CardView(frame: .zero)
        cardView.images = user!.profileImages
        if let photoUrlString = user!.profileImages {
            let photoUrl = URL(string: photoUrlString[0])
            cardView.imageView.sd_setImage(with: photoUrl)
        }
        (0..<user!.profileImages!.count).forEach { (_) in
            let barView = UIView()
            barView.backgroundColor = UIColor(white: 0, alpha: 0.1)
            barView.layer.cornerRadius = barView.frame.size.height / 2
            barsStackView.addArrangedSubview(barView)
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
        }
        
        let nametraits = [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]
        var nameFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family: "Avenir Next"])
        nameFontDescriptor = nameFontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: nametraits])
        
        let agetraits = [UIFontDescriptor.TraitKey.weight: UIFont.Weight.light]
        var ageFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family: "Avenir Next"])
        ageFontDescriptor = ageFontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: agetraits])
        
        let jobtraits = [UIFontDescriptor.TraitKey.weight: UIFont.Weight.light]
        var jobFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family: "Avenir Next"])
        jobFontDescriptor = jobFontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: jobtraits])
        
        let attributedText = NSMutableAttributedString(string: user!.name!, attributes: [.font: UIFont(descriptor: nameFontDescriptor, size: 30)])
        attributedText.append(NSAttributedString(string: " \(user!.age!)", attributes: [.font: UIFont(descriptor: ageFontDescriptor, size: 24)]))
        if user!.profession != "" && user!.company != "" {
            attributedText.append(NSAttributedString(string: "\n\(user!.profession!) @ \(user!.company!)", attributes: [.font: UIFont(descriptor: jobFontDescriptor, size: 20)]))
        }

        // TODO
//        cardView.informationLabel.attributedText = attributedText
        
        cardView.addSubview(gradientView)
        cardView.addSubview(barsStackView)
        cardView.stackView = barsStackView
        cardView.userId = user!.id!
        barsStackView.anchor(top: cardView.topAnchor, leading: cardView.leadingAnchor, bottom: nil, trailing: cardView.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
        
        self.cardView = cardView
    }
    
}
