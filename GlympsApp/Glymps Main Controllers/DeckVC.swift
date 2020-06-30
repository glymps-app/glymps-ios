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

class DeckVC: UIViewController, iCarouselDataSource, iCarouselDelegate, MoreInfoDelegate {
    
    @IBOutlet weak var refreshUsersBtn: UIButton!
    
    @IBOutlet weak var refreshUsersImage: UIImageView!
    
    @IBOutlet weak var noUsersView: UIView! // image if no nearby users found
    
    // Put Smaato Banner View Here

    @IBOutlet weak var cardsDeckView: UpSwipableCarousel!
    
    @IBOutlet weak var mapButton: UIButton!

    @IBOutlet weak var nearbyUserCountLabel: UILabel!
    
    @IBOutlet weak var headerView: UIView!

    var users: [User] = []
    
    var cachedUsers: [User] = []
    
    var requests: [String] = []
    
    var matches: [String] = []
    
    var blockedUsers: [String] = []
    
    var permanentlyBlockedUsers: [String] = []
    
    var ghostModeUsers: [String] = []
    
    var cardViews: [DeckCardView] = []
    
    //var bannerAds: [SMABannerView] = []
    
    var userId: String?
    
    var currentUsername: String?
    
    var currentUser: User?
    
    let hud = JGProgressHUD(style: .extraLight)
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        observeDeck()
    }

    // setup UI and backend systems (Geolocation – GeoFire, Premium, Firebase)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPusher()

        setupCurrentUser()
        loadRequests()
        loadMatches()
        loadBlockedUsers()
        loadPermanentlyBlockedUsers()
        loadGhostModeUsers()

        cardsDeckView.type = .rotary
        cardsDeckView.bounceDistance = 0.35
        cardsDeckView.decelerationRate = 0.80
        cardsDeckView.isPagingEnabled = false

        mapButton.layer.cornerRadius = 21.0
        mapButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        mapButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        mapButton.layer.shadowOpacity = 1
        mapButton.layer.shadowRadius = 10
        mapButton.addTarget(self, action: #selector(handleMap), for: .touchUpInside)

        refreshUsersBtn.isEnabled = false

        refreshUsersImage.isHidden = true

        refreshUsersBtn.isHidden = true

        configureLocationManager()
        observeDeck()

        checkIfPremium()

        noUsersView.isHidden = true

        hud.textLabel.text = "Loading nearby users..."
        hud.layer.zPosition = 50
        hud.show(in: view)

//        // setup views
//        let stackView = UIStackView(arrangedSubviews: [headerView, cardsDeckView])
//        stackView.axis = .vertical
//        view.addSubview(stackView)
//        stackView.frame = .init(x: 0, y: 0, width: 300, height: 200)
//        stackView.fillSuperview()
//        stackView.isLayoutMarginsRelativeArrangement = true
//        stackView.bringSubviewToFront(cardsDeckView)

        let deleteGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        (cardsDeckView.value(forKey: "contentView") as! UIView).addGestureRecognizer(deleteGestureRecognizer)
        deleteGestureRecognizer.accessibilityLabel = "foo"
        deleteGestureRecognizer.delegate = cardsDeckView
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

        viewDidLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        headerView.layer.cornerRadius = (UIScreen.main.bounds.width + 1600.0) / 2
//        headerView.layer.shadowOffset = CGSize(width: 0, height: 1)
//        headerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.22).cgColor
//        headerView.layer.shadowOpacity = 1
//        headerView.layer.shadowRadius = 10
        headerView.clipsToBounds = true
        headerView.layer.masksToBounds = false
    }
    
    // get current user
    func setupCurrentUser() {
        API.User.observeCurrentUser { (user) in
            self.currentUser = user
            self.currentUsername = user.name ?? ""
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
                if purchaserInfo.activeSubscriptions.contains("com.glymps.Glymps.1MonthUSD") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (1 month subscription)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("com.glymps.Glymps.6MonthUSD") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (6 month subscription)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("com.glymps.Glymps.12MonthUSD") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (1 year subscription)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("com.glymps.Glymps.1MonthCoin") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (1 month subscription, coin)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("com.glymps.Glymps.6MonthCoin") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (6 month subscription, coin)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("com.glymps.Glymps.12MonthCoin") {
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
                    } else if (user.id != API.User.CURRENT_USER?.uid) && (currentUser.preferedGender == "Both") &&
                        (currentUser.gender == user.preferedGender) &&
                        (currentUser.minAge!...currentUser.maxAge! ~= user.age!) &&
                        (user.minAge!...user.maxAge! ~= currentUser.age!) &&
                        !strongSelf.requests.contains(user.id!) && !strongSelf.matches.contains(user.id!) && !strongSelf.blockedUsers.contains(user.id!) &&
                        !strongSelf.permanentlyBlockedUsers.contains(user.id!) &&
                        !strongSelf.ghostModeUsers.contains(user.id!) {
                        strongSelf.cachedUsers.append(user)
                    } else if (user.id != API.User.CURRENT_USER?.uid) &&
                        (user.preferedGender == "Both") &&
                        (currentUser.preferedGender == user.gender) &&
                        (currentUser.minAge!...currentUser.maxAge! ~= user.age!) &&
                        (user.minAge!...user.maxAge! ~= currentUser.age!) &&
                        !strongSelf.requests.contains(user.id!) && !strongSelf.matches.contains(user.id!) && !strongSelf.blockedUsers.contains(user.id!) &&
                        !strongSelf.permanentlyBlockedUsers.contains(user.id!) &&
                        !strongSelf.ghostModeUsers.contains(user.id!) {
                        strongSelf.cachedUsers.append(user)
                    } else if (user.id != API.User.CURRENT_USER?.uid) &&
                        ((currentUser.preferedGender == "Both") && (user.preferedGender == "Both")) &&
                        (currentUser.minAge!...currentUser.maxAge! ~= user.age!) &&
                        (user.minAge!...user.maxAge! ~= currentUser.age!) &&
                        !strongSelf.requests.contains(user.id!) && !strongSelf.matches.contains(user.id!) && !strongSelf.blockedUsers.contains(user.id!) &&
                        !strongSelf.permanentlyBlockedUsers.contains(user.id!) &&
                        !strongSelf.ghostModeUsers.contains(user.id!) {
                        strongSelf.cachedUsers.append(user)
                    }
                }
                
                strongSelf.hud.dismiss()
                strongSelf.updateDeckAndRefreshButtonState()
            }
        }.add(to: connectionGroup)
    }

    func updateDeckAndRefreshButtonState() {
        if users.isEmpty {
            users = cachedUsers
            cachedUsers = []
            setupCards()
            cardsDeckView.reloadData()
        } else if cachedDeckMatchesCurrentDeck() {
            cachedUsers = []
        }

        refreshUsersBtn.isHidden = cachedUsers.isEmpty
        refreshUsersImage.isHidden = cachedUsers.isEmpty
        refreshUsersBtn.isEnabled = !cachedUsers.isEmpty

        noUsersView.isHidden = !users.isEmpty
    }
    
    func cachedDeckMatchesCurrentDeck() -> Bool {
        return Set(users.compactMap { $0.id }) == Set(cachedUsers.compactMap { $0.id })
    }
    
    @IBAction func refreshUsersBtnWasPressed(_ sender: Any) {
        users = []
        updateDeckAndRefreshButtonState()
    }
        
    func loadRequests() {
        
        self.requests = []
        
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
        
        self.matches = []
        
        API.Inbox.loadMatchesDeck { (user) in
            if user.id != API.User.CURRENT_USER?.uid {
                self.matches.insert(user.id!, at: 0)
            }
            print("Matches:", self.matches)
        }
    }
    
    func loadBlockedUsers() {
        
        self.blockedUsers = []
        
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
        
        self.permanentlyBlockedUsers = []
        
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
        
        self.ghostModeUsers = []
        
        // load ghost mode users (users that want to go inactive for 24 hours max)
        
        API.Inbox.loadUsersInGhostMode { (user) in
            let ghostModeUser = user as! User
            if ghostModeUser.id != API.User.CURRENT_USER!.uid {
                self.ghostModeUsers.insert(ghostModeUser.id!, at: 0)
            }
        }
    }
    
    // go to user details screen
    @objc func moreInfoTapped(sender: UIButton) {
        let data = cardViews[sender.tag].userId
        let cv = cardViews[sender.tag]
        let userDetailsController = UserDetailsVC()
        userDetailsController.userId = data
//        userDetailsController.cardView = cv
        userDetailsController.presenter = self
        present(userDetailsController, animated: true, completion: nil)
    }
    
    // go to user details screen when card, not info button, is tapped, other than edges
    func goToMoreInfo(userId: String, cardView: CardView) {
        let data = userId
        let cv = cardView
        let userDetailsController = UserDetailsVC()
        userDetailsController.userId = data
        userDetailsController.cardView = cv
        userDetailsController.presenter = self
        present(userDetailsController, animated: true, completion: nil)
    }

    // go to chat to message a user
    @objc func messageUserTapped(sender: UIButton) {
        let data = cardViews[sender.tag].userId
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.userId = data
        chatVC.currentUsername = self.currentUsername
        chatVC.currentUser = self.currentUser
        chatVC.deckVC = self
        self.navigationController?.pushViewController(chatVC, animated: true)
        
        // go to specific user chat after this transition
    }
    
    var indexForCards = 0
    
    func setupCards() {
        cardViews = []
        indexForCards = 0

        nearbyUserCountLabel.text = "\(users.count)"

        for user in users {
            let cardView = DeckCardView.loadFromNib()

//            if UIDevice.modelName == "Simulator iPhone 6" || UIDevice.modelName == "Simulator iPhone 6s" || UIDevice.modelName == "Simulator iPhone 7" || UIDevice.modelName == "Simulator iPhone 8" || UIDevice.modelName == "iPhone 6" || UIDevice.modelName == "iPhone 6s" || UIDevice.modelName == "iPhone 7" || UIDevice.modelName == "iPhone 8" {
//                cardView = CardView(frame: CGRect(x: 0, y: 0, width: 320, height: 500))
//            } else if UIDevice.modelName == "Simulator iPhone 6 Plus" || UIDevice.modelName == "Simulator iPhone 7 Plus" || UIDevice.modelName == "Simulator iPhone 8 Plus" || UIDevice.modelName == "iPhone 6 Plus" || UIDevice.modelName == "iPhone 7 Plus" || UIDevice.modelName == "iPhone 8 Plus" {
//                cardView = CardView(frame: CGRect(x: 0, y: 0, width: 370, height: 570))
//            } else if UIDevice.modelName == "Simulator iPhone X" || UIDevice.modelName == "Simulator iPhone XS" || UIDevice.modelName == "Simulator iPhone 11 Pro" || UIDevice.modelName == "iPhone X" || UIDevice.modelName == "iPhone XS" || UIDevice.modelName == "iPhone 11 Pro" {
//                cardView = CardView(frame: CGRect(x: 0, y: 0, width: 320, height: 580))
//            } else if UIDevice.modelName == "Simulator iPhone XS Max" || UIDevice.modelName == "Simulator iPhone 11 Pro Max" || UIDevice.modelName == "iPhone XS Max" || UIDevice.modelName == "iPhone 11 Pro Max" {
//                cardView = CardView(frame: CGRect(x: 0, y: 0, width: 370, height: 600))
//            } else if UIDevice.modelName == "Simulator iPhone XR" || UIDevice.modelName == "Simulator iPhone 11" || UIDevice.modelName == "iPhone XR" || UIDevice.modelName == "iPhone 11" {
//                cardView = CardView(frame: CGRect(x: 0, y: 0, width: 370, height: 580))
//            }
            cardView.moreInfoDelegate = self
//            let gradientView = GlympsGradientView()
//            let barsStackView = UIStackView()
//            let moreInfoButton = UIButton(type: .system)
//            moreInfoButton.setImage(#imageLiteral(resourceName: "info_icon").withRenderingMode(.alwaysOriginal), for: .normal)
//            moreInfoButton.isUserInteractionEnabled = true
//            moreInfoButton.addTarget(self, action: #selector(moreInfoTapped(sender:)), for: .touchUpInside)
//            let messageUserButton = UIButton(type: .system)
//            messageUserButton.setImage(#imageLiteral(resourceName: "message-icon2").withRenderingMode(.alwaysOriginal), for: .normal)
//            messageUserButton.isUserInteractionEnabled = true
//            messageUserButton.addTarget(self, action: #selector(messageUserTapped(sender:)), for: .touchUpInside)
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

            self.userId = user.id
            cardView.images = user.profileImages
            if let photoUrlString = user.profileImages {
                let photoUrl = URL(string: photoUrlString[0])
                cardView.imageView.sd_setImage(with: photoUrl)
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

            cardView.configure(with: user, atIndex: indexForCards)
//            cardView.informationLabel.attributedText = attributedText

//            cardView.addSubview(gradientView)
//            cardView.addSubview(barsStackView)
//            cardView.addSubview(moreInfoButton)
//            cardView.addSubview(messageUserButton)
            cardView.addSubview(cycleLeftButton)
            cardView.addSubview(cycleRightButton)
//            cardView.moreInfoButton = moreInfoButton
//            cardView.messageUserButton = messageUserButton
            cardView.cycleLeftButton = cycleLeftButton
            cardView.cycleRightButton = cycleRightButton
            cardView.userId = self.userId
            cardView.moreInfoButton?.tag = indexForCards
//            cardView.messageUserButton?.tag = indexForCards
            cardView.cycleLeftButton?.tag = indexForCards
            cardView.cycleRightButton?.tag = indexForCards
            cardView.cycleLeftButton?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cardView.cycleRightButton?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cardView.tag = indexForCards

            cycleLeftButton.anchor(top: nil, leading: cardView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 8, bottom: 0, right: 0), size: .init(width: 50, height: 50))
            cycleLeftButton.centerYToSuperview()
            cycleRightButton.anchor(top: nil, leading: nil, bottom: nil, trailing: cardView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 8), size: .init(width: 50, height: 50))
            cycleRightButton.centerYToSuperview()
            
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
        cardViews.count
    }

//    var lastItemIndex = 0
//    var lastOffset: CGFloat = 0.0
//
//    func carouselWillBeginDragging(_ carousel: iCarousel) {
//        lastItemIndex = carousel.currentItemIndex
//        lastOffset = carousel.offsetForItem(at: lastItemIndex)
//    }
//
//    func carouselDidEndDragging(_ carousel: iCarousel, willDecelerate decelerate: Bool) {
//        if decelerate == false {
//            carousel.itemView(at: lastItemIndex)?.layer.removeAllAnimations()
//            if carousel.offsetForItem(at: lastItemIndex) < lastOffset {
//                carousel.scrollToItem(at: lastItemIndex + 1, animated: true)
//            } else {
//                carousel.scrollToItem(at: lastItemIndex - 1, animated: true)
//            }
//        }
//    }

    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .spacing:
            return 1.15 //1.15 //1.03
        case .arc:
            return CGFloat(Double.pi / 2)
        case .visibleItems:
            return 3.0
        case .showBackfaces:
            return 0.0
        case .count:
            return 4.0
        case .wrap:
            return carousel.numberOfItems > 2 ? 1.0 : 0.0
        case .angle:
            return value
        default:
            return value
        }
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let card = cardViews[index]
        card.frame = cardsDeckView.bounds.insetBy(dx: 32, dy: 0)
        return card
    }

    @objc func handlePanGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        guard let currentCard = cardsDeckView.currentItemView as? DeckCardView else { return }
        let translation = sender.translation(in: view)

        switch sender.state {
        case .began:
            break
        case .ended, .cancelled, .failed:
            if -translation.y > currentCard.frame.height / 2 {
                UIView.animate(withDuration: 0.3, animations: {
                    currentCard.imageView.alpha = 0.0
                    currentCard.transform = currentCard.transform.translatedBy(x: 0.0, y: -400)
                }, completion: { _ in
                    self.blockCurrentCard()
                })
            } else {
                UIView.animate(withDuration: 0.3) {
                    currentCard.imageView.alpha = 1.0
                    currentCard.transform = CGAffineTransform.identity
                }
            }
        case .changed:
            if translation.y < 0 {
                currentCard.imageView.alpha = 1 + (translation.y / currentCard.frame.height / 2)
                currentCard.transform = CGAffineTransform.identity.translatedBy(x: 0.0, y: translation.y)
            } else {
                currentCard.transform = CGAffineTransform.identity
            }
        default:
            break
        }
    }

    func blockCurrentCard() {
        let index = cardsDeckView.currentItemIndex
        let card = cardViews[index]

        guard let uid = card.userId else { return }

        cardViews.remove(at: index)
        users = users.filter { $0.id != uid }
        cachedUsers = cachedUsers.filter { $0.id != uid }
        API.Inbox.blockUser(uid: uid)
        cardsDeckView.removeItem(at: index, animated: true)

        updateDeckAndRefreshButtonState()
    }
    
    func blockFromOtherVC() {
        let index = cardsDeckView.currentItemIndex
        let card = cardViews[index]

        guard let uid = card.userId else { return }

        cardViews.remove(at: index)
        users = users.filter { $0.id != uid }
        cachedUsers = cachedUsers.filter { $0.id != uid }
        cardsDeckView.removeItem(at: index, animated: true)

        updateDeckAndRefreshButtonState()
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

class UpSwipableCarousel: iCarousel, UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.accessibilityLabel == "foo", let panGR = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGR.translation(in: self)
            return -translation.y > abs(translation.x)
        } else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
    }
}
