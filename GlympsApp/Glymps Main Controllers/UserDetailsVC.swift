//
//  UserDetailsVC.swift
//  GlympsApp
//
//  Created by James B Morris on 7/7/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import SDWebImage

// screen for a user to view another user's info and learn more about them
class UserDetailsVC: UIViewController, UIScrollViewDelegate {
    
    var currentUsername: String?
    
    var currentUser: User?
    
    var presenter: UIViewController?
    
    lazy var scrollView: UIScrollView = {
       let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        sv.delegate = self
        return sv
    }()
    
    // setup profile image display
    let swipingPhotosController = SwipingPhotosController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    let bioLabel: UILabel = {
       let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    let dismissButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "blue-down-arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let messageUserButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "message-icon2").withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleMessage), for: .touchUpInside)
        return button
    }()
    
    let blockUserButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "remove-user").withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleBlock), for: .touchUpInside)
        return button
    }()
    
    let buttonStack: UIStackView = {
       let stack = UIStackView()
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var userId: String?
    
    let biotraits = [UIFontDescriptor.TraitKey.weight: UIFont.Weight.light]
    var bioFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family: "Avenir Next"])
    
    // setup cardViews of other user
    var cardView: CardView! {
        didSet {
            
            infoLabel.attributedText = cardView.informationLabel.attributedText
            
            swipingPhotosController.cardView = cardView
            
            API.User.observeUsers(withId: userId!) { (user) in
                if let bio = user.bio {
                    self.bioFontDescriptor = self.bioFontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: self.biotraits])
                    let attributedText = NSMutableAttributedString(string: bio, attributes: [.font: UIFont(descriptor: self.bioFontDescriptor, size: 18)])
                    self.bioLabel.attributedText = attributedText
                }
            }
            
        }
    }

    // setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCurrentUser()
        
        self.modalPresentationStyle = .fullScreen
        
        setupLayout()
        
        setupBlurView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let id = self.userId {
                print(id)
            }
        }
    }
    
    // get current user
    func setupCurrentUser() {
        API.User.observeCurrentUser { (user) in
            self.currentUser = user
            self.currentUsername = user.name!
            print("Current user: \(self.currentUser!)")
        }
    }
    
    // setup layout of views as well as contraints
    func setupLayout() {
        
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        let imageView = swipingPhotosController.view!
        
        scrollView.addSubview(imageView)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: imageView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: imageView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        scrollView.addSubview(bioLabel)
        bioLabel.anchor(top: infoLabel.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: imageView.trailingAnchor, padding: .init(top: 25, left: 16, bottom: 0, right: 16))
        
        scrollView.addSubview(dismissButton)
        dismissButton.anchor(top: imageView.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 25), size: .init(width: 50, height: 50))
        
        buttonStack.addArrangedSubview(messageUserButton)
        messageUserButton.withHeight(50)
        messageUserButton.withWidth(50)
        
        buttonStack.addArrangedSubview(blockUserButton)
        blockUserButton.withHeight(50)
        blockUserButton.withWidth(50)
        
        scrollView.addSubview(buttonStack)
        buttonStack.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 80, bottom: 20, right: 80))
    }
    
    // prep to setup up profile image layout
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let imageView = swipingPhotosController.view!
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + 80)
        
    }
    
    // setup blur above profile images
    func setupBlurView() {
        
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.alpha = 0.5
        
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    // setup image scroll direction
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        let imageView = swipingPhotosController.view!
        imageView.frame = CGRect(x: min(0, -changeY), y: min(0, -changeY), width: width, height: width + 80)
    }
    
    // dismiss user detail view and go back to "card deck"
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // go to chat view controller and send other user a message
    @objc func handleMessage() {
        
        dismiss(animated: true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.userId = self.userId
        chatVC.currentUsername = self.currentUsername
        chatVC.currentUser = self.currentUser
        chatVC.deckVC = presenter
        self.presenter!.navigationController?.pushViewController(chatVC, animated: true)
        
        // go to specific user chat after this transition
    }
    
    // block other user and go into "ghost mode"
    @objc func handleBlock() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let blockOptionsVC = storyboard.instantiateViewController(withIdentifier: "BlockOptionsVC") as! BlockOptionsVC
        blockOptionsVC.userId = self.userId
        blockOptionsVC.userDetailsVC = self
        self.present(blockOptionsVC, animated: true, completion: nil)
    }
    


}
