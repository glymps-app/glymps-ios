//
//  ProfileImageVC.swift
//  Glymps
//
//  Created by James B Morris on 5/7/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import JGProgressHUD
import CoreLocation
import GeoFire
import CropViewController
import Amplitude_iOS

// view controller to set up new user profile image during onboarding
class ProfileImageVC: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    var userEmail = ""
    var userPassword = ""
    var userName = ""
    var userBio = ""
    var userProfession =  ""
    var userCompany = ""
    var userAge = Int()
    var userGender = ""
    var userGenderPreference = ""
    
    // setup GeoFire
    var userLat = ""
    var userLong = ""
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    
    var picker = UIImagePickerController()
    
    var selectedProfileImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        print(userEmail)
        print(userPassword)
        print(userName)
        print(userBio)
        print(userProfession)
        print(userCompany)
        print(userAge)
        print(userGender)
        print(userGenderPreference)
    
        nextBtn.isEnabled = false
        nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        nextBtn.layer.borderWidth = 1
        
        // tap gesture to choose profile image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileImageVC.handleSelectProfileImageView))
        profileImageView.addGestureRecognizer(tapGesture)

    }
    
    // handle tap of profileImage
    @objc func handleSelectProfileImageView() {
        let alert = UIAlertController(title: "Glymps", message: "Please select a source:", preferredStyle: UIAlertController.Style.actionSheet)
        let camera = UIAlertAction(title: "Take a selfie", style: UIAlertAction.Style.default) { (_) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.picker.sourceType = .camera
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Option unavailable.")
            }
        }
        let library = UIAlertAction(title: "Choose an image", style: UIAlertAction.Style.default) { (_) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                self.picker.sourceType = .photoLibrary
                self.picker.mediaTypes = [String(kUTTypeImage)]
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Option unavailable.")
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // move to next view controller and pass necessary data
    @IBAction func nextBtnWasPressed(_ sender: Any) {
    
        let name = userName
        let gender = userGender
        let age = userAge
        let email = userEmail
        let password = userPassword
        let bio = userBio
        let profession = userProfession
        let company = userCompany
        let preferredGender = userGenderPreference
        let coins = 10
        let isPremium = false
        let minAge = 18
        let maxAge = 80
        
        let hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = "Signing you up..."
        hud.show(in: view)
        
        // set preferred gender
        if let profileImg = self.selectedProfileImage, let imageData = profileImg.jpegData(compressionQuality: 0.1) {
            
            // sign up new Glymps user! then go to OnboardDoneVC to celebrate :)
            AuthService.signUp(name: name, gender: gender, email: email, password: password, age: age, bio: bio, profession: profession, company: company, coins: coins, isPremium: isPremium, minAge: minAge, maxAge: maxAge, preferedGender: preferredGender, imageData: imageData, onSuccess: {
                
                if referringUser != "" {
                    self.logAmplitudeReferredUserSignupEvent(email: email, age: age, profession: profession, company: company, name: name, gender: gender, coins: coins, isPremium: isPremium, minAge: minAge, maxAge: maxAge, preferredGender: preferredGender)
                } else {
                    self.logAmplitudeNewUserSignupEvent(email: email, age: age, profession: profession, company: company, name: name, gender: gender, coins: coins, isPremium: isPremium, minAge: minAge, maxAge: maxAge, preferredGender: preferredGender)
                }
                
                hud.textLabel.text = "Welcome to Glymps! \u{1F389}"
                hud.dismiss(afterDelay: 4.0)
                
                let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
                let onboardDoneVC = storyboard.instantiateViewController(withIdentifier: "OnboardDoneVC") as! OnboardDoneVC
                self.navigationController?.pushViewController(onboardDoneVC, animated: true)
            }) {
                hud.textLabel.text = "Whoops, something's not right. \u{1F615}"
                hud.dismiss(afterDelay: 4.0)
                self.nextBtn.wiggle()
            }
        }
    }
    
    func logAmplitudeOnboardingStepNineOfNineCompleteProfileImageEvent() {
        Amplitude.instance().logEvent("Onboarding Step 9/9 Complete (Profile Image)")
    }
    
    func logAmplitudeNewUserSignupEvent(email: String, age: Int, profession: String, company: String, name: String, gender: String, coins: Int, isPremium: Bool, minAge: Int, maxAge: Int, preferredGender: String) {
        var newUserSignupEventProperties: [AnyHashable : Any] = [:]
        newUserSignupEventProperties.updateValue(email as Any, forKey: "Email")
        newUserSignupEventProperties.updateValue(age as Any, forKey: "Age")
        newUserSignupEventProperties.updateValue(profession as Any, forKey: "Profession")
        newUserSignupEventProperties.updateValue(company as Any, forKey: "Company")
        newUserSignupEventProperties.updateValue(name as Any, forKey: "Name")
        newUserSignupEventProperties.updateValue(gender as Any, forKey: "Gender")
        newUserSignupEventProperties.updateValue(coins as Any, forKey: "Number of Glymps Coins")
        newUserSignupEventProperties.updateValue(isPremium as Any, forKey: "Subscription Status")
        newUserSignupEventProperties.updateValue(minAge as Any, forKey: "Minimum Preferred Age")
        newUserSignupEventProperties.updateValue(maxAge as Any, forKey: "Maximum Preferred Age")
        newUserSignupEventProperties.updateValue(preferredGender as Any, forKey: "Preferred Gender")
        Amplitude.instance().logEvent("New User (Sign Up)", withEventProperties: newUserSignupEventProperties)
    }
    
    func logAmplitudeReferredUserSignupEvent(email: String, age: Int, profession: String, company: String, name: String, gender: String, coins: Int, isPremium: Bool, minAge: Int, maxAge: Int, preferredGender: String) {
        var referredUserSignupEventProperties: [AnyHashable : Any] = [:]
        referredUserSignupEventProperties.updateValue(email as Any, forKey: "Email")
        referredUserSignupEventProperties.updateValue(age as Any, forKey: "Age")
        referredUserSignupEventProperties.updateValue(profession as Any, forKey: "Profession")
        referredUserSignupEventProperties.updateValue(company as Any, forKey: "Company")
        referredUserSignupEventProperties.updateValue(name as Any, forKey: "Name")
        referredUserSignupEventProperties.updateValue(gender as Any, forKey: "Gender")
        referredUserSignupEventProperties.updateValue(coins as Any, forKey: "Number of Glymps Coins")
        referredUserSignupEventProperties.updateValue(isPremium as Any, forKey: "Subscription Status")
        referredUserSignupEventProperties.updateValue(minAge as Any, forKey: "Minimum Preferred Age")
        referredUserSignupEventProperties.updateValue(maxAge as Any, forKey: "Maximum Preferred Age")
        referredUserSignupEventProperties.updateValue(preferredGender as Any, forKey: "Preferred Gender")
        Amplitude.instance().logEvent("Referred User Signup", withEventProperties: referredUserSignupEventProperties)
    }


}

// image picker for user to choose profile image
extension ProfileImageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedProfileImage = image
        }
        dismiss(animated: true, completion: nil)
        
        let image: UIImage = selectedProfileImage! //Load an image
        
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
        
        nextBtn.isEnabled = true
        nextBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
        nextBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        nextBtn.layer.borderWidth = 1
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        profileImageView.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
