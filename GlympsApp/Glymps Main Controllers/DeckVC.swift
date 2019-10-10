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
import JGProgressHUD
import Purchases
import CoreLocation
import GeoFire
import SmaatoSDKCore
import SmaatoSDKBanner
import SmaatoSDKInterstitial

class DeckVC: UIViewController {
    
    @IBOutlet weak var noUsersView: UIView! // image if no nearby users found
    
    var bannerView: SMABannerView? // Smaato medium-sized rectangle banner advertisement
    
    var interstitial: SMAInterstitial? // Smaato full-screen interstitial advertisement
    
    let headerView = UIView() // top view (Glymps + heatmap)
    // TODO: change this cardsDeckView below from a third-party SLCarouselView to UICollectionView for expanded UI capabilities
    let cardsDeckView = SLCarouselView(coder: NSCoder.empty()) // "card deck" carousels
    let menuView = BottomNavigationStackView() // bottom navigation bar
    
    var users: [User] = []
    
    var requests: [String] = []
    
    var matches: [String] = []
    
    var blockedUsers: [String] = []
    
    var permanentlyBlockedUsers: [String] = []
    
    var cardViews: [CardView] = []
    
    var bannerAds: [SMABannerView] = []
    
    var userId: String?
    
    let hud = JGProgressHUD(style: .extraLight)
    
    let mapBtn: UIButton = {
       let button = UIButton(type: .system)
        button.titleLabel?.text = ""
        button.setBackgroundImage(#imageLiteral(resourceName: "globe"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "heat-map").withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.alpha = 0.6
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

    // setup UI and backend systems (Geolocation – GeoFire, Premium, Firebase)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationManager()
        
        mapBtn.layer.zPosition = 30
        headerView.addSubview(mapBtn)
        headerView.bringSubviewToFront(mapBtn)
        mapBtn.anchor(top: nil, leading: headerView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 35, bottom: 0, right: 0), size: .init(width: 50, height: 50))
        mapBtn.centerYToSuperview()
        mapBtn.isUserInteractionEnabled = true
        
        setupDeviceToken()
        
        checkIfPremium()
        
        noUsersView.isHidden = true
        
        hud.textLabel.text = "Loading nearby users..."
        hud.layer.zPosition = 50
        hud.show(in: view)
        
        loadRequests()
        loadMatches()
        loadBlockedUsers()
        loadPermanentlyBlockedUsers()
        
        headerView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        menuView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        // setup views
        let stackView = UIStackView(arrangedSubviews: [headerView, cardsDeckView!, menuView])
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.frame = .init(x: 0, y: 0, width: 300, height: 200)
        stackView.fillSuperview()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        stackView.bringSubviewToFront(cardsDeckView!)
        
        menuView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        menuView.messagesButton.addTarget(self, action: #selector(handleMessages), for: .touchUpInside)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.setupAds()
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
    
    // get current user's device token for push notifications
    func setupDeviceToken() {
        
        let defaults = UserDefaults.standard
        let hasSetDeviceToken = defaults.bool(forKey: "hasSetDeviceToken")
        if !hasSetDeviceToken {
        Database.database().reference().child("deviceTokens").child(API.User.CURRENT_USER!.uid).updateChildValues(["deviceToken":userDeviceToken])
            
            UserDefaults.standard.set(true, forKey: "hasSetDeviceToken")
        } else {
            return
        }
    }
    
    // add Smaato ad to Advertiser View
    func addBannerViewToView(_ bannerView: SMABannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerAds.append(bannerView)
    }
    
    // check if current user is a Glymps Premium user
    func checkIfPremium() {
        
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if let purchaserInfo = purchaserInfo {
                
                print(purchaserInfo.activeSubscriptions)
                
                // Option 1: Check if user has access to entitlement (from RevenueCat dashboard)
                if purchaserInfo.activeEntitlements.contains("pro") {
                    print("User has access to Glymps entitlements!")
                } else {
                    print("User does not have access to Glymps entitlements!")
                }

                // Option 2: Check if user has active subscription (from App Store Connect or Play Store)
                if purchaserInfo.activeSubscriptions.contains("JamesBMorris.GlympsApp.USDSubscription1Month") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (1 mo subscription)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("JamesBMorris.GlympsApp.USDSubscription6Month") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (6 mo subscription)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("JamesBMorris.GlympsApp.USDSubscription12Month") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (12 mo subscription)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("JamesBMorris.GlympsApp.CoinSubscription1Month") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (1 mo coin subscription)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("JamesBMorris.GlympsApp.CoinSubscription6Month") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (6 mo coin subscription)")
                    AuthService.subscribe()
                } else if purchaserInfo.activeSubscriptions.contains("JamesBMorris.GlympsApp.CoinSubscription12Month") {
                    // Grant user "pro" access
                    print("User has Glymps Premium (12 mo coin subscription)")
                    AuthService.subscribe()
                } else {
                    // User is not premium
                    print("User does not have Glymps Premium!")
                    AuthService.unsubscribe()
                }
            }
        }
        
    }
    
    // any updated purchases from RevenueCat?
    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: PurchaserInfo) {
        // handle any changes to purchaserInfo
    }
    
    // setup mobile ads from Smaato
    func setupAds() {
        let bV = SMABannerView()
        bV.autoreloadInterval = .veryShort
        bV.delegate = self
        bV.load(withAdSpaceId: "0", adSize: .mediumRectangle_300x250)
        self.bannerView = bV
        self.bannerView?.fillSuperview()
        if let bV = bannerView {
            bannerAds.append(bV)
        } else {
            print("Banner view is nil.")
        }
        setupBannerAdCards()
    }

    func observeDeck() {
        deckService.observeDeck { [weak self] deck in
            API.User.observeCurrentUser { currentUser in
                guard let strongSelf = self else { return }

                strongSelf.users = []

                for card in deck {
                    let user = card.user
                    if (user.id != API.User.CURRENT_USER?.uid) && (currentUser.preferedGender == user.gender) && (currentUser.minAge!...currentUser.maxAge! ~= user.age!) && !strongSelf.requests.contains(user.id!) && !strongSelf.matches.contains(user.id!) && !strongSelf.blockedUsers.contains(user.id!) {
                        print(user.name!)
                        strongSelf.users.append(user)
                        strongSelf.noUsersView.isHidden = true
                    } else if (user.id != API.User.CURRENT_USER?.uid) && (currentUser.preferedGender == "Both") && (currentUser.minAge!...currentUser.maxAge! ~= user.age!) {
                        print(user.name!)
                        strongSelf.users.append(user)
                        strongSelf.noUsersView.isHidden = true
                    } else if strongSelf.bannerAds != [] {
                        strongSelf.noUsersView.isHidden = true
                    } else {
                        strongSelf.hud.dismiss()
                        strongSelf.noUsersView.isHidden = false
                    }
                }

                strongSelf.setupCards()
            }
        }.add(to: connectionGroup)
    }

    // find nearby users in 400 foot radius of current user
    func findUsers(completion: @escaping (User) -> Void) {

        if queryHandle != nil, myQuery != nil {
            myQuery.removeObserver(withFirebaseHandle: queryHandle!)
            queryHandle = nil
            myQuery = nil
        }
        
        guard let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String, let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String else {
            return
        }
        
        // query geolocations of nearby users with GeoFire
        let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
        self.users.removeAll()
        myQuery = geoFire.query(at: location, withRadius: 0.12) // load users within 400 feet
        queryHandle = myQuery.observe(.keyEntered) { (key, location) in
            if key != API.User.CURRENT_USER!.uid {
                API.User.observeUsers(withId: key, completion: { (user) in
                    completion(user)
                })
            }
        }
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
        let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessagesVC") as! MessagesVC
        messagesVC.userId = data
        self.present(messagesVC, animated: true, completion: nil)
        
        // go to specific user chat after this transition
    }
    
    var index = 0
    
    // setup nearby user cards
    func setupCards() {
        for user in users {
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
            gradientView.layer.opacity = 0.5
            let cardView = CardView(frame: .zero)
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
            cardView.moreInfoButton = moreInfoButton
            cardView.messageUserButton = messageUserButton
            cardView.stackView = barsStackView
            cardView.userId = self.userId
            cardView.moreInfoButton?.tag = index
            cardView.messageUserButton?.tag = index
            moreInfoButton.anchor(top: nil, leading: nil, bottom: cardView.bottomAnchor, trailing: cardView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 20, right: 20), size: .init(width: 50, height: 50))
            messageUserButton.anchor(top: cardView.topAnchor, leading: nil, bottom: nil, trailing: cardView.trailingAnchor, padding: .init(top: 25, left: 0, bottom: 0, right: 25), size: .init(width: 44, height: 44))
            barsStackView.anchor(top: cardView.topAnchor, leading: cardView.leadingAnchor, bottom: nil, trailing: cardView.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
            barsStackView.spacing = 4
            barsStackView.distribution = .fillEqually
            cardView.fillSuperview()
            gradientView.fillSuperview()
            
            hud.textLabel.text = "All done! \u{1F389}"
            hud.dismiss(afterDelay: 0.0)
            
            self.index += 1
            self.cardViews.append(cardView)
            
            self.cardsDeckView?.appendContent(view: cardView)
        }
        self.noUsersView.isHidden = true
    }
    
    // setup mobile ad cards
    func setupBannerAdCards() {
        
        API.User.observeCurrentUser { (user) in
            if user.isPremium == false {
                //self.callWhenYouNeedInterstitial()
                for banner in self.bannerAds {
                    let advertiserView = AdvertiserView(frame: .zero)
                    print("BANNER: \(banner)")
                    advertiserView.addSubview(banner)
                    advertiserView.bannerView = banner
                    banner.anchor(top: advertiserView.topAnchor, leading: advertiserView.leadingAnchor, bottom: advertiserView.bottomAnchor, trailing: advertiserView.trailingAnchor)
                    advertiserView.fillSuperview()

                    self.cardsDeckView?.appendContent(view: advertiserView)
                }
                print("Banners: \(self.bannerAds.count)")
            }
        }
        self.noUsersView.isHidden = true
    }
    
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
            
            geoFire.setLocation(location, forKey: API.User.CURRENT_USER!.uid) { [weak self] error in
                if error != nil { return }
                self?.authAPI.location.addTimestamp()
            }
        }
    }
    
}

extension DeckVC: SMABannerViewDelegate {

    func presentingViewController(for bannerView: SMABannerView) -> UIViewController {
        return self
    }

    func bannerViewDidTTLExpire(_ bannerView: SMABannerView) {
        print("TTL Expired.")
    }

}

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
