//
//  MatchView.swift
//  GlympsApp
//
//  Created by James B Morris on 8/11/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// view and animation when two users match
class MatchView: UIView {
    
    // set up profile images of matching users
    var userId: String! {
        didSet {
            API.User.observeCurrentUser { (user) in
                self.currentUserImage.sd_setImage(with: URL(string: user.profileImages!.first!))
                self.currentUserImage.alpha = 1
            }
            API.User.observeUsers(withId: userId) { (user) in
                self.otherUserImage.sd_setImage(with: URL(string: user.profileImages!.first!))
                self.otherUserImage.alpha = 1
            }
            setupAnimations()
        }
    }
    
    // "hooray" image for the match!
    let partyPopperImage: UIImageView = {
       let imageView = UIImageView(image: #imageLiteral(resourceName: "party-popper-emoji"))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // setup description label
    var username: String? {
        didSet {
            descriptionLabel.text = "Congratulations!\n\(username ?? "") is interested in you!"
        }
    }
    
    // chat view controller that passes this view data to display
    var chatVC: ChatVC!
    
    // description label
    let descriptionLabel: UILabel = {
       let label = UILabel()
        label.text = ""
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        label.font = UIFont(name: "Avenir-Medium", size: 19)
        label.numberOfLines = 0
        return label
    }()
    
    // image of app's current user
    let currentUserImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        imageView.alpha = 0
        return imageView
    }()
    
    // image of other user current user is matching with
    let otherUserImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        imageView.alpha = 0
        return imageView
    }()
    
    // button to continue sending other user messages
    let continueMessagingButton: UIButton = {
       let button = GlympsGradientButton(type: .system)
        button.setTitle("CONTINUE MESSAGING", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    // button to return to inbox and message matched user later
    let messageLaterButton: UIButton = {
        let button = GlympsGradientBorderButton(type: .system)
        button.setTitle("Message Later", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(messageLater), for: .touchUpInside)
        return button
    }()

    // setup views and subview layouts
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBlurView()
        setupLayout()
        
    }
    
    // blur view
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    // make cool animation when match occurs
    func setupAnimations() {
        
        let angle = 30 * CGFloat.pi / 180
        
        currentUserImage.transform = CGAffineTransform(rotationAngle: -angle).concatenating(CGAffineTransform(translationX: 200, y: 0))
        otherUserImage.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: -200, y: 0))
        continueMessagingButton.transform = CGAffineTransform(translationX: -500, y: 0)
        messageLaterButton.transform = CGAffineTransform(translationX: 500, y: 0)
        
        UIView.animateKeyframes(withDuration: 1.3, delay: 0, options: .calculationModeCubic, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45, animations: {
                self.currentUserImage.transform = CGAffineTransform(rotationAngle: -angle)
                self.otherUserImage.transform = CGAffineTransform(rotationAngle: angle)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.5, animations: {
                self.currentUserImage.transform = .identity
                self.otherUserImage.transform = .identity
            })
            
        }) { (_) in
            
        }
        
        UIView.animate(withDuration: 0.75, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            self.continueMessagingButton.transform = .identity
            self.messageLaterButton.transform = .identity
        })
        
    }
    
    // add subviews to view and layout views
    func setupLayout() {
        
        addSubview(partyPopperImage)
        addSubview(descriptionLabel)
        addSubview(currentUserImage)
        addSubview(otherUserImage)
        addSubview(continueMessagingButton)
        addSubview(messageLaterButton)
        
        partyPopperImage.anchor(top: nil, leading: nil, bottom: descriptionLabel.topAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .init(width: 150, height: 150))
        partyPopperImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        descriptionLabel.anchor(top: nil, leading: self.leadingAnchor, bottom: currentUserImage.topAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0), size: .init(width: 0, height: 80))
        
        currentUserImage.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: 140, height: 140))
        currentUserImage.layer.cornerRadius = 70
        currentUserImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        otherUserImage.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: 140, height: 140))
        otherUserImage.layer.cornerRadius = 70
        otherUserImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        continueMessagingButton.anchor(top: currentUserImage.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 32, left: 48, bottom: 0, right: 48), size: .init(width: 0, height: 60))
        continueMessagingButton.layer.cornerRadius = 30
        
        messageLaterButton.anchor(top: continueMessagingButton.bottomAnchor, leading: continueMessagingButton.leadingAnchor, bottom: nil, trailing: continueMessagingButton.trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 60))
        messageLaterButton.layer.cornerRadius = 30
        
    }
    
    // setup blur view
    func setupBlurView() {
        
        addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        visualEffectView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.visualEffectView.alpha = 1
        }) { (_) in
            
        }
        
    }
    
    // close view
    @objc func handleDismiss() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 0
            self.removeFromSuperview()
            self.removeFromSuperview()
        }) { (_) in
            
        }
    }
    
    // close view and navigate to inbox
    @objc func messageLater() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 0
            self.removeFromSuperview()
            self.removeFromSuperview()
        }) { (_) in
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            self.chatVC.view.window!.layer.add(transition, forKey: kCATransition)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessagesVC")
            self.chatVC.present(messagesVC, animated: true, completion: nil)
        }
    }
    
    
    
    // default view encoder
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
