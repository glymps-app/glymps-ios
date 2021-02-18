//
//  ShareGlympsVC.swift
//  GlympsApp
//
//  Created by James B Morris on 9/29/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks
import Amplitude_iOS

class ShareGlympsVC: UIViewController {
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    @IBOutlet weak var shareWithCodeBtn: UIButton!
    
    @IBOutlet weak var inviteContactBtn: UIButton!
    
    @IBOutlet weak var ambassadorSignupBtn: UIButton!
    
    var imageURL: URL?
    
    var shareURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logAmplitudeReferralsViewedEvent()
        
        shareWithCodeBtn.layer.cornerRadius = 8
        shareWithCodeBtn.layer.borderWidth = 1
        shareWithCodeBtn.layer.borderColor = #colorLiteral(red: 0, green: 0.7123068571, blue: 1, alpha: 1)

        setupCode()
    }
    
    func setupCode() {
        API.User.observeCurrentUser { (user) in
            
            let profileImages = user.profileImages
            if let profileImage = profileImages?[0], let photoUrl = URL(string: profileImage) {
                self.imageURL = photoUrl
            }
            
            guard let uid = API.User.CURRENT_USER?.uid else { return }
            
            var components = URLComponents()
            components.scheme = "https"
            components.host = "www.glympsapp.io"
            components.path = "/referrals"
            
            let newUserQueryItem = URLQueryItem(name: "referringUser", value: "\(uid)")
            
            components.queryItems = [newUserQueryItem]
            
            guard let link = components.url else { return }
            
            guard let referralLink = DynamicLinkComponents.init(link: link, domainURIPrefix: "https://glympsdating.page.link") else {
                print("Couldn't create URL components :(")
                return
            }

            referralLink.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.glymps.glymps-date")
            referralLink.iOSParameters?.minimumAppVersion = "1.0.0"
            // set app store id. Glymps' is 1493810382, but for now we are using Tinder's
            referralLink.iOSParameters?.appStoreID = "1493810382"
            
            referralLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
            referralLink.socialMetaTagParameters?.title = "\(user.name!) wants you to come sign up for Glymps!"
            referralLink.socialMetaTagParameters?.descriptionText = "Date naturally. Make moments. Break the ice. Sign up for Glymps and change the way you date!"
            referralLink.socialMetaTagParameters?.imageURL = self.imageURL
            
            referralLink.shorten { (shortURL, warnings, error) in
              if let error = error {
                print(error.localizedDescription)
                return
              }
              let linkString = shortURL!.absoluteString
              self.shareWithCodeBtn.setTitle(linkString, for: .normal)
                self.shareURL = shortURL
            }
        }
    }
    
    @IBAction func dismissBtnWasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func shareWithCodeBtnWasPressed(_ sender: Any) {
        self.logAmplitudeReferViaReferralCodeEvent()
        let promoText = "Date naturally! Come join Glymps Dating, this dating app I found that is changing the game."
        let activityController = UIActivityViewController(activityItems: [promoText, shareURL ?? ""], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func inviteContactBtnWasPressed(_ sender: Any) {
        self.logAmplitudeReferViaContactEvent()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contactsVC = storyboard.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsVC
        contactsVC.shareableLink = shareWithCodeBtn.titleLabel!.text!
        self.present(contactsVC, animated: true, completion: nil)
    }
    
    @IBAction func ambassadorBtnWasPressed(_ sender: Any) {
        // go to campus ambassador onboarding
    }
    
    func logAmplitudeReferralsViewedEvent() {
        Amplitude.instance().logEvent("Referrals Viewed")
    }
    
    func logAmplitudeReferViaReferralCodeEvent() {
        API.User.observeCurrentUser { (user) in
            var referViaReferralCodeEventProperties: [AnyHashable : Any] = [:]
            referViaReferralCodeEventProperties.updateValue(user.email as Any, forKey: "Email")
            referViaReferralCodeEventProperties.updateValue(user.age as Any, forKey: "Age")
            referViaReferralCodeEventProperties.updateValue(user.profession as Any, forKey: "Profession")
            referViaReferralCodeEventProperties.updateValue(user.company as Any, forKey: "Company")
            referViaReferralCodeEventProperties.updateValue(user.name as Any, forKey: "Name")
            referViaReferralCodeEventProperties.updateValue(user.gender as Any, forKey: "Gender")
            referViaReferralCodeEventProperties.updateValue(user.id as Any, forKey: "User ID")
            referViaReferralCodeEventProperties.updateValue(user.coins as Any, forKey: "Number of Glymps Coins")
            referViaReferralCodeEventProperties.updateValue(user.isPremium as Any, forKey: "Subscription Status")
            referViaReferralCodeEventProperties.updateValue(user.minAge as Any, forKey: "Minimum Preferred Age")
            referViaReferralCodeEventProperties.updateValue(user.maxAge as Any, forKey: "Maximum Preferred Age")
            referViaReferralCodeEventProperties.updateValue(user.preferedGender as Any, forKey: "Preferred Gender")
            Amplitude.instance().logEvent("Refer Via Referral Code Initiated", withEventProperties: referViaReferralCodeEventProperties)
        }
    }
    
    func logAmplitudeReferViaContactEvent() {
        API.User.observeCurrentUser { (user) in
            var referViaContactEventProperties: [AnyHashable : Any] = [:]
            referViaContactEventProperties.updateValue(user.email as Any, forKey: "Email")
            referViaContactEventProperties.updateValue(user.age as Any, forKey: "Age")
            referViaContactEventProperties.updateValue(user.profession as Any, forKey: "Profession")
            referViaContactEventProperties.updateValue(user.company as Any, forKey: "Company")
            referViaContactEventProperties.updateValue(user.name as Any, forKey: "Name")
            referViaContactEventProperties.updateValue(user.gender as Any, forKey: "Gender")
            referViaContactEventProperties.updateValue(user.id as Any, forKey: "User ID")
            referViaContactEventProperties.updateValue(user.coins as Any, forKey: "Number of Glymps Coins")
            referViaContactEventProperties.updateValue(user.isPremium as Any, forKey: "Subscription Status")
            referViaContactEventProperties.updateValue(user.minAge as Any, forKey: "Minimum Preferred Age")
            referViaContactEventProperties.updateValue(user.maxAge as Any, forKey: "Maximum Preferred Age")
            referViaContactEventProperties.updateValue(user.preferedGender as Any, forKey: "Preferred Gender")
            Amplitude.instance().logEvent("Refer Via Contact Initiated", withEventProperties: referViaContactEventProperties)
        }
    }
}
