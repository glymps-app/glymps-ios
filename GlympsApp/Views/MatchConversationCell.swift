//
//  MatchConversationCell.swift
//  GlympsApp
//
//  Created by James B Morris on 7/31/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// cell for displaying current user's recent messages with matches
class MatchConversationCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var cardView: CardView!

    // setup matched user
    var user: User? {
        didSet {
            usernameLabel.text = ""
            updateUser()
        }
    }
    
    // setup most recent message
    var messages: [Message] = [] {
        didSet {
            messageLabel.text = ""
            updateMessage()
        }
    }
    
    // setup profile image, username, and recent message within cell, and setup CardView to pass to chat controller so current user can view requesting user's details
    func updateUser() {
            
        if let photoUrlString = user!.profileImages?.first {
            let photoUrl = URL(string: photoUrlString)
            self.profileImage.sd_setImage(with: photoUrl)
        }
            
        self.usernameLabel.text = user!.name
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
        
        cardView.informationLabel.attributedText = attributedText
        
        cardView.addSubview(gradientView)
        cardView.addSubview(barsStackView)
        cardView.stackView = barsStackView
        cardView.userId = user!.id!
        barsStackView.anchor(top: cardView.topAnchor, leading: cardView.leadingAnchor, bottom: nil, trailing: cardView.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
        
        self.cardView = cardView
        
    }
    
    // function for setting up cell from inbox controller
    func configureCell(uid: String) {
        API.Messages.retrieveMessages(from: uid, to: API.User.CURRENT_USER!.uid) { (message) in
            self.messages.append(message)
            self.sortMessages()
        }
        
        API.Messages.retrieveMessages(from: API.User.CURRENT_USER!.uid, to: uid) { (message) in
            self.messages.append(message)
            self.sortMessages()
        }
    }
    
    // sort for most recent message
    func sortMessages() {
        messages = messages.sorted(by: { $0.date < $1.date })
    }
    
    // change message text to message if text, or [MEDIA] if photo/video
    func updateMessage() {
        if let lastMessage = messages.last?.text {
            if lastMessage == "" {
                messageLabel.text = "[MEDIA]"
            } else {
                messageLabel.text = lastMessage
            }
        }
    }

}
