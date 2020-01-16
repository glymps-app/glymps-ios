//
//  DeckVC.swift
//  Glymps
//
//  Created by James B Morris on 4/29/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import SDWebImage
import SLCarouselView
import iCarousel
import JGProgressHUD
import Purchases
import CoreLocation
import GeoFire
import PushNotifications
//import SmaatoSDKCore
//import SmaatoSDKBanner
//import SmaatoSDKInterstitial

class DeckVC: UIViewController, iCarouselDataSource, iCarouselDelegate, MoreInfoDelegate {
    
    @IBOutlet weak var refreshUsersBtn: UIButton!
    
    @IBOutlet weak var refreshUsersImage: UIImageView!
    
    @IBOutlet weak var noUsersView: UIView! // image if no nearby users found
    
    // Put Smaato Banner View Here
    
    let headerView = UIView() // top view (Glymps + heatmap)
    
    @IBOutlet weak var cardsDeckView: iCarousel!
    
    let menuView = BottomNavigationStackView() // bottom navigation bar
    
    var users: [User] = []
    
    var cachedUsers: [User] = []
    
    var requests: [String] = []
    
    var matches: [String] = []
    
    var blockedUsers: [String] = []
    
    var permanentlyBlockedUsers: [String] = []
    
    var ghostModeUsers: [String] = []
    
    var cardViews: [CardView] = []
    
    //var bannerAds: [SMABannerView] = []
    
    var userId: String?
    
    var currentUsername: String?
    
    var currentUser: User?
    
    let hud = JGProgressHUD(style: .extraLight)
    
    let mapBtn: UIButton = {
       let button = UIButton(type: .system)
        button.titleLabel?.text = ""
        button.setBackgroundImage(#imageLiteral(resourceName: "globe"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "heat-map").withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        //button.imageView?.alpha = 0.6
        button.imageView?.image?.withAlignmentRectInsets(UIEdgeInsets(top: -2, left: -4, bottom: 2, right: 0))
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleMap), for: .touchUpInside)
        return button
    }()
    
    // setup GeoFire
    var userLat = ""
    var userLong = ""
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    let manager = CLLocationManager()
    var myQuery: GFQuery!
    var queryHandle: DatabaseHandle?
    let authAPI = AuthAPI(user: Auth.auth().currentUser!)
    lazy var deckService = DeckService(authAPI: authAPI)
    let connectionGroup = ConnectionGroup()
    
    var currentUserReferredBy: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCurrentUser()
        loadRequests()
        loadMatches()
        loadBlockedUsers()
        loadPermanentlyBlockedUsers()
        loadGhostModeUsers()
        
        observeDeck()
    }

    // setup UI and backend systems (Geolocation – GeoFire, Premium, Firebase)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPusher()
        
        menuView.glympsImage.tintColor = #colorLiteral(red: 0, green: 0.7123068571, blue: 1, alpha: 1)
        menuView.settingsButton.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        menuView.messagesButton.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        setupCurrentUser()
        loadRequests()
        loadMatches()
        loadBlockedUsers()
        loadPermanentlyBlockedUsers()
        loadGhostModeUsers()
        
        cardsDeckView.type = .linear
        cardsDeckView.bounceDistance = 3.00
        cardsDeckView.decelerationRate = 3.00
        
        refreshUsersBtn.isEnabled = false
        
        refreshUsersImage.isHidden = true
        
        refreshUsersBtn.isHidden = true
        
        configureLocationManager()
        observeDeck()
        
        mapBtn.layer.zPosition = 30
        headerView.addSubview(mapBtn)
        headerView.bringSubviewToFront(mapBtn)
        mapBtn.anchor(top: nil, leading: headerView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 35, bottom: 0, right: 0), size: .init(width: 50, height: 50))
        mapBtn.centerYToSuperview()
        mapBtn.isUserInteractionEnabled = true
        
        checkIfPremium()
        
        noUsersView.isHidden = true
        
        hud.textLabel.text = "Loading nearby users..."
        hud.layer.zPosition = 50
        hud.show(in: view)
        
        headerView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        menuView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        // setup views
         
        let stackView = UIStackView(arrangedSubviews: [headerView, cardsDeckView, menuView])
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.frame = .init(x: 0, y: 0, width: 300, height: 200)
        stackView.fillSuperview()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        stackView.bringSubviewToFront(cardsDeckView)
        
        menuView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        menuView.messagesButton.addTarget(self, action: #selector(handleMessages), for: .touchUpInside)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.setupAds()
//        }
        
        self.view.bringSubviewToFront(refreshUsersBtn)
        self.view.bringSubviewToFront(refreshUsersImage)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Users in Ghost Mode: \(self.ghostModeUsers)")
        }
        
        if currentUserReferredBy != "" {
            rewardReferralUser(refUser: currentUserReferredBy, coinAmount: 3)
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
    
    func rewardReferralUser(refUser: String, coinAmount: Int) {
        
        var newCoins = coinAmount
        
        API.User.observeUsers(withId: refUser) { (user) in
            newCoins += user.coins!
        Database.database().reference().child("users").child(refUser).updateChildValues(["coins" : newCoins]) { (error, ref) in }
        }
    }
    
    // setup location manager to get current user location, live
    func configureLocationManager() {
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = true
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
        
        self.geoFireRef = Database.database().reference().child("Geolocs")
        self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
    }
    
    // setup Pusher for current user's uid
    func setupPusher() {
        
        let tokenProvider = BeamsTokenProvider(authURL: "https://glymps-pusher-notifications.herokuapp.com/pusher/beams-auth") { () -> AuthData in
          let headers = ["Authorization": "Bearer"] // Headers your auth endpoint needs
            let queryParams: [String: String] = ["user_id":API.User.CURRENT_USER!.uid] // URL query params your auth endpoint needs
            return AuthData(headers: headers, queryParams: queryParams)
        }
        
        beamsClient.setUserId(API.User.CURRENT_USER!.uid, tokenProvider: tokenProvider, completion: { error in
          guard error == nil else {
            print("Failed to authenticate with Pusher Beams. Error: \(error?.localizedDescription ?? "")")
              return
          }

          print("Successfully authenticated with Pusher Beams")
        })
        
    }
    
    
//    // add Smaato ad to Advertiser View
//    func addBannerViewToView(_ bannerView: SMABannerView) {
//        bannerView.translatesAutoresizingMaskIntoConstraints = false
//        bannerAds.append(bannerView)
//    }
    
    // check if current user is a Glymps Premium user
    func checkIfPremium() {

        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if let purchaserInfo = purchaserInfo {

                print(purchaserInfo.activeSubscriptions)
                // Option 1: Check if user has access to entitlement (from RevenueCat dashboard)
                if purchaserInfo.entitlements["pro"]?.isActive == true {
                  print("User has access to Glymps Premium.")
                }

//                // Option 2: Check if user has active subscription (from App Store Connect or Play Store)
                if purchaserInfo.activeSubscriptions.contains("com.glymps.Glymps.1MonthUSDSubscription") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (1 month subscription)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("com.glymps.Glymps.6MonthUSDSubscription") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (6 month subscription)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("com.glymps.Glymps.12MonthUSDSubscription") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (1 year subscription)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("com.glymps.Glymps.1MonthCoinSubscription") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (1 month subscription, coin)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("com.glymps.Glymps.6MonthCoinSubscription") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (6 month subscription, coin)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("com.glymps.Glymps.12MonthCoinSubscription") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (1 year subscription, coin)")
                    AuthService.subscribe()
                } else {
                    // User is not premium
                    print("User does not have Glymps Premium!")
                    AuthService.unsubscribe()
                }
            }
        }

    }
    
//    // setup mobile ads from Smaato
//    func setupAds() {
//        let bV = SMABannerView()
//        bV.autoreloadInterval = .veryShort
//        bV.delegate = self
//        bV.load(withAdSpaceId: "0", adSize: .mediumRectangle_300x250)
//        self.bannerView = bV
//        self.bannerView?.fillSuperview()
//        if let bV = bannerView {
//            bannerAds.append(bV)
//        } else {
//            print("Banner view is nil.")
//        }
//        //setupBannerAdCards()
//    }

    func observeDeck() {
        deckService.observeDeck { [weak self] deck in
            API.User.observeCurrentUser { currentUser in
                guard let strongSelf = self else { return }

                strongSelf.cachedUsers = []

                for card in deck {
                    let user = card.user
                    if (user.id != API.User.CURRENT_USER?.uid) && (currentUser.preferedGender == user.gender) &&
                        (currentUser.gender == user.preferedGender) &&
                        (currentUser.minAge!...currentUser.maxAge! ~= user.age!) &&
                        (user.minAge!...user.maxAge! ~= currentUser.age!) &&
                        !strongSelf.requests.contains(user.id!) && !strongSelf.matches.contains(user.id!) && !strongSelf.blockedUsers.contains(user.id!) &&
                        !strongSelf.permanentlyBlockedUsers.contains(user.id!) &&
                        !strongSelf.ghostModeUsers.contains(user.id!) {
                        strongSelf.cachedUsers.append(user)
                        strongSelf.noUsersView.isHidden = true
                    } else if (user.id != API.User.CURRENT_USER?.uid) && (currentUser.preferedGender == "Both") &&
                        (currentUser.gender == user.preferedGender) &&
                        (currentUser.minAge!...currentUser.maxAge! ~= user.age!) &&
                        (user.minAge!...user.maxAge! ~= currentUser.age!) &&
                        !strongSelf.requests.contains(user.id!) && !strongSelf.matches.contains(user.id!) && !strongSelf.blockedUsers.contains(user.id!) &&
                        !strongSelf.permanentlyBlockedUsers.contains(user.id!) &&
                        !strongSelf.ghostModeUsers.contains(user.id!) {
                        strongSelf.cachedUsers.append(user)
                        strongSelf.noUsersView.isHidden = true
//                    } else if strongSelf.bannerAds != [] {
//                        strongSelf.noUsersView.isHidden = true
                    } else if (user.id != API.User.CURRENT_USER?.uid) &&
                        (user.preferedGender == "Both") &&
                        (currentUser.preferedGender == user.gender) &&
                        (currentUser.minAge!...currentUser.maxAge! ~= user.age!) &&
                        (user.minAge!...user.maxAge! ~= currentUser.age!) &&
                        !strongSelf.requests.contains(user.id!) && !strongSelf.matches.contains(user.id!) && !strongSelf.blockedUsers.contains(user.id!) &&
                        !strongSelf.permanentlyBlockedUsers.contains(user.id!) &&
                        !strongSelf.ghostModeUsers.contains(user.id!) {
                        strongSelf.cachedUsers.append(user)
                        strongSelf.noUsersView.isHidden = true
                    } else if (user.id != API.User.CURRENT_USER?.uid) &&
                        ((currentUser.preferedGender == "Both") && (user.preferedGender == "Both")) &&
                        (currentUser.minAge!...currentUser.maxAge! ~= user.age!) &&
                        (user.minAge!...user.maxAge! ~= currentUser.age!) &&
                        !strongSelf.requests.contains(user.id!) && !strongSelf.matches.contains(user.id!) && !strongSelf.blockedUsers.contains(user.id!) &&
                        !strongSelf.permanentlyBlockedUsers.contains(user.id!) &&
                        !strongSelf.ghostModeUsers.contains(user.id!) {
                        strongSelf.cachedUsers.append(user)
                        strongSelf.noUsersView.isHidden = true
                    } else {
                        strongSelf.hud.dismiss()
                        strongSelf.noUsersView.isHidden = false
                    }
                }

                if strongSelf.users.isEmpty {
                    strongSelf.users = strongSelf.cachedUsers
                    strongSelf.setupCards()
                    strongSelf.cardsDeckView.reloadData()
                } else {
                   // Show refresh button
                    
                    strongSelf.refreshUsersImage.isHidden = false
                    
                    strongSelf.refreshUsersBtn.isHidden = false
                    
                    strongSelf.refreshUsersBtn.isEnabled = true
                }
            }
        }.add(to: connectionGroup)
    }
    
    @IBAction func refreshUsersBtnWasPressed(_ sender: Any) {
        
        self.users = self.cachedUsers
        self.cardsDeckView.reloadData()
        
        self.refreshUsersImage.isHidden = true
        self.refreshUsersBtn.isHidden = true
        self.refreshUsersBtn.isEnabled = false
    }
        
    func loadRequests() {
        
        // load new message requests
        
        API.Inbox.loadMessageRequestsDeck { (user) in
            if user.id != API.User.CURRENT_USER?.uid {
                
                self.requests.insert(user.id!, at: 0)
            }
            print("Requests:", self.requests)
        }
    }
    
    func loadMatches() {
        
        // load matched users
        
        API.Inbox.loadMatchesDeck { (user) in
            if user.id != API.User.CURRENT_USER?.uid {
                self.matches.insert(user.id!, at: 0)
            }
            print("Matches:", self.matches)
        }
    }
    
    func loadBlockedUsers() {
        
        // load blocked users (only blocked for 24 hours)
        
        API.Inbox.loadBlockedUsersDeck { (user) in
            let blockedUser = user as! User
            if blockedUser.id != API.User.CURRENT_USER!.uid {
                self.blockedUsers.insert(blockedUser.id!, at: 0)
            }
            print("Blocked Users:", self.blockedUsers)
        }
    }
    
    func loadPermanentlyBlockedUsers() {
        
        // load permanently blocked users (blocked indefinitely)
        
        API.Inbox.loadPermanentlyBlockedUsersDeck { (user) in
            let permanentlyBlockedUser = user as! User
            if permanentlyBlockedUser.id != API.User.CURRENT_USER!.uid {
                self.permanentlyBlockedUsers.insert(permanentlyBlockedUser.id!, at: 0)
            }
            print("Blocked Users:", self.permanentlyBlockedUsers)
        }
    }
    
    func loadGhostModeUsers() {
        
        // load ghost mode users (users that want to go inactive for 24 hours max)
        
        API.Inbox.loadUsersInGhostMode { (user) in
            let ghostModeUser = user as! User
            if ghostModeUser.id != API.User.CURRENT_USER!.uid {
                self.ghostModeUsers.insert(ghostModeUser.id!, at: 0)
            }
        }
    }
    
    // go to main profile screen
    @objc func handleSettings() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC")
        self.present(profileVC, animated: true, completion: nil)
    }
    
    // go to inbox
    @objc func handleMessages() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessagesVC") as! MessagesVC
        self.present(messagesVC, animated: true, completion: nil)
    }
    
    // go to user details screen
    @objc func moreInfoTapped(sender: UIButton) {
        let data = cardViews[sender.tag].userId
        let cv = cardViews[sender.tag]
        let userDetailsController = UserDetailsVC()
        userDetailsController.userId = data
        userDetailsController.cardView = cv
        present(userDetailsController, animated: true, completion: nil)
    }
    
    // go to user details screen when card, not info button, is tapped, other than edges
    func goToMoreInfo(userId: String, cardView: CardView) {
        let data = userId
        let cv = cardView
        let userDetailsController = UserDetailsVC()
        userDetailsController.userId = data
        userDetailsController.cardView = cv
        present(userDetailsController, animated: true, completion: nil)
    }

    // go to chat to message a user
    @objc func messageUserTapped(sender: UIButton) {
        let data = cardViews[sender.tag].userId
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.userId = data
        chatVC.currentUsername = self.currentUsername
        chatVC.currentUser = self.currentUser
        self.present(chatVC, animated: true, completion: nil)
        
        // go to specific user chat after this transition
    }
    
    var indexForCards = 0
    
    func setupCards() {
        for user in users {
            let cardView = CardView(frame: CGRect(x: 0, y: 0, width: 370, height: 570))
            cardView.moreInfoDelegate = self
            let gradientView = GlympsGradientView()
            let barsStackView = UIStackView()
            let moreInfoButton = UIButton(type: .system)
            moreInfoButton.setImage(#imageLiteral(resourceName: "info_icon").withRenderingMode(.alwaysOriginal), for: .normal)
            moreInfoButton.isUserInteractionEnabled = true
            moreInfoButton.addTarget(self, action: #selector(moreInfoTapped(sender:)), for: .touchUpInside)
            let messageUserButton = UIButton(type: .system)
            messageUserButton.setImage(#imageLiteral(resourceName: "message-icon2").withRenderingMode(.alwaysOriginal), for: .normal)
            messageUserButton.isUserInteractionEnabled = true
            messageUserButton.addTarget(self, action: #selector(messageUserTapped(sender:)), for: .touchUpInside)
            let cycleLeftButton = UIButton(type: .system)
            if #available(iOS 13.0, *) {
                cycleLeftButton.setImage(UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                continue
            }
            cycleLeftButton.isUserInteractionEnabled = true
            let cycleRightButton = UIButton(type: .system)
            if #available(iOS 13.0, *) {
                cycleRightButton.setImage(UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                continue
            }
            cycleRightButton.isUserInteractionEnabled = true
            gradientView.layer.opacity = 0.5
            self.userId = user.id
            cardView.images = user.profileImages
            if let photoUrlString = user.profileImages {
                let photoUrl = URL(string: photoUrlString[0])
                cardView.imageView.sd_setImage(with: photoUrl)
            }
            (0..<user.profileImages!.count).forEach { (_) in
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
                
            let attributedText = NSMutableAttributedString(string: user.name!, attributes: [.font: UIFont(descriptor: nameFontDescriptor, size: 30)])
            attributedText.append(NSAttributedString(string: " \(user.age!)", attributes: [.font: UIFont(descriptor: ageFontDescriptor, size: 24)]))
            if user.profession != "" && user.company != "" {
                attributedText.append(NSAttributedString(string: "\n\(user.profession!) @ \(user.company!)", attributes: [.font: UIFont(descriptor: jobFontDescriptor, size: 20)]))
            }
                
            cardView.informationLabel.attributedText = attributedText
                
            cardView.addSubview(gradientView)
            cardView.addSubview(barsStackView)
            cardView.addSubview(moreInfoButton)
            cardView.addSubview(messageUserButton)
            cardView.addSubview(cycleLeftButton)
            cardView.addSubview(cycleRightButton)
            cardView.moreInfoButton = moreInfoButton
            cardView.messageUserButton = messageUserButton
            cardView.cycleLeftButton = cycleLeftButton
            cardView.cycleRightButton = cycleRightButton
            cardView.stackView = barsStackView
            cardView.userId = self.userId
            cardView.moreInfoButton?.tag = indexForCards
            cardView.messageUserButton?.tag = indexForCards
            cardView.cycleLeftButton?.tag = indexForCards
            cardView.cycleRightButton?.tag = indexForCards
            cardView.cycleLeftButton?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cardView.cycleRightButton?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            moreInfoButton.anchor(top: nil, leading: nil, bottom: cardView.bottomAnchor, trailing: cardView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 20, right: 20), size: .init(width: 50, height: 50))
            messageUserButton.anchor(top: cardView.topAnchor, leading: nil, bottom: nil, trailing: cardView.trailingAnchor, padding: .init(top: 25, left: 0, bottom: 0, right: 25), size: .init(width: 44, height: 44))
            cycleLeftButton.anchor(top: nil, leading: cardView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 8, bottom: 0, right: 0), size: .init(width: 50, height: 50))
            cycleLeftButton.centerYToSuperview()
            cycleRightButton.anchor(top: nil, leading: nil, bottom: nil, trailing: cardView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 8), size: .init(width: 50, height: 50))
            cycleRightButton.centerYToSuperview()
            barsStackView.anchor(top: cardView.topAnchor, leading: cardView.leadingAnchor, bottom: nil, trailing: cardView.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
            barsStackView.spacing = 4
            barsStackView.distribution = .fillEqually
            //cardView.fillSuperview()
            gradientView.fillSuperview()
            
            if (cardView.imageIndex == 0) && (user.profileImages!.count > 1) {
                cycleLeftButton.isHidden = true
                cycleLeftButton.isEnabled = false
                cycleRightButton.isHidden = false
                cycleRightButton.isEnabled = true
            } else {
                cycleLeftButton.isHidden = true
                cycleLeftButton.isEnabled = false
                cycleRightButton.isHidden = true
                cycleRightButton.isEnabled = false
            }
                
            hud.textLabel.text = "All done! \u{1F389}"
            hud.dismiss(afterDelay: 0.0)
                
            self.indexForCards += 1
            self.cardViews.append(cardView)
            self.noUsersView.isHidden = true
        }
    }
    
    // setup nearby user cards
    func numberOfItems(in carousel: iCarousel) -> Int {
        users.count
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.01
        }
        return value
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
//        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: 370, height: 570))
//        tempView.layer.cornerRadius = 15
//        tempView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
//
//        return tempView
        
        return cardViews[index]
    }
    
    // setup mobile ad cards
//    func setupBannerAdCards() {
//
//        API.User.observeCurrentUser { (user) in
//            if user.isPremium == false {
//                //self.callWhenYouNeedInterstitial()
//                for banner in self.bannerAds {
//                    let advertiserView = AdvertiserView(frame: .zero)
//                    print("BANNER: \(banner)")
//                    advertiserView.addSubview(banner)
//                    advertiserView.bannerView = banner
//                    banner.anchor(top: advertiserView.topAnchor, leading: advertiserView.leadingAnchor, bottom: advertiserView.bottomAnchor, trailing: advertiserView.trailingAnchor)
//                    advertiserView.fillSuperview()
//
//                    //self.cardsDeckView?.appendContent(view: advertiserView)
//                }
//                print("Banners: \(self.bannerAds.count)")
//            }
//        }
//        self.noUsersView.isHidden = true
//    }
    
//    func callWhenYouNeedInterstitial() {
//        SmaatoSDK.loadInterstitial(forAdSpaceId: "0",                                                     delegate: self)
//    }
    
    // go to heat map to find concentrations of nearby users
    @objc func handleMap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        self.present(mapVC, animated: true, completion: nil)
    }
    
    
}

// check on authorization status for location manager
extension DeckVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {
            
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location services authorization error: \(error.localizedDescription)")
    }
    
    // update current location of current user whenever changed, on Firebase via GeoFire
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.delegate = nil
        let updatedLocation: CLLocation = locations.first!
        let newCoordinate: CLLocationCoordinate2D = updatedLocation.coordinate
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.setValue("\(newCoordinate.latitude)", forKey: "current_location_latitude")
        userDefaults.setValue("\(newCoordinate.longitude)", forKey: "current_location_longitude")
        userDefaults.synchronize()
        
        if let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String, let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String {
            
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
            
            geoFire.setLocation(location, forKey: API.User.CURRENT_USER!.uid) { error in //[weak self] error in
                print("[RESULT]: " + String(describing: error))
//                if error != nil { return }
//                self?.authAPI.location.addTimestamp()
            }
        }
    }
    
}

//extension DeckVC: SMABannerViewDelegate {
//
//    func presentingViewController(for bannerView: SMABannerView) -> UIViewController {
//        return self
//    }
//
//    func bannerViewDidTTLExpire(_ bannerView: SMABannerView) {
//        print("TTL Expired.")
//    }
//
//}

//extension DeckVC: SMAInterstitialDelegate {
//    // Interstitial did successfully loaded
//    func interstitialDidLoad(_ interstitialResponse: SMAInterstitial) {
//        self.interstitial = interstitialResponse
//        interstitialResponse.show(from: self)
//    }
//
//    // Interstitial did fail loading
//    func interstitial(_ interstitial: SMAInterstitial?, didFailWithError error: Error) {
//        print("Interstitial did fail loading with error: \(error.localizedDescription)")
//    }
//
//    // Interstitial ads TTL has expired
//    func interstitialDidTTLExpire(_ interstitial: SMAInterstitial) {
//        print("Interstitial TTL has expired")
//    }
//}

// default encoder
extension NSCoder {
    class func empty() -> NSCoder {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.finishEncoding()
        return NSKeyedUnarchiver(forReadingWith: data as Data)
    }
}

// extension to prevent duplication of users
extension Array {
    public mutating func appendDistinct<S>(contentsOf newElements: S, where condition:@escaping (Element, Element) -> Bool) where S : Sequence, Element == S.Element {
        newElements.forEach { (item) in
            if !(self.contains(where: { (selfItem) -> Bool in
                return !condition(selfItem, item)
            })) {
                self.append(item)
            }
        }
    }
}
