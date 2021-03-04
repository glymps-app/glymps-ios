//
//  LoginVC.swift
//  Glymps
//
//  Created by James B Morris on 5/6/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import JGProgressHUD
import Amplitude_iOS

// main screen upon app entry for user to enter credentials and sign-in
class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!

    @IBOutlet weak var signInBtn: UIButton!

    @IBOutlet weak var toSignUpBtn: UIButton!
    
    var identify: AMPIdentify?

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        
        emailTextfield.tag = 0
        passwordTextfield.tag = 1
        
        emailTextfield.returnKeyType = UIReturnKeyType.next
        passwordTextfield.returnKeyType = UIReturnKeyType.go

        signInBtn.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        signInBtn.layer.borderWidth = 1
        
        signInBtn.isEnabled = false
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(LoginVC.keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)
        
        handleTextField()
    }
    
    // see if user is first-timer, if yes display walkthrough view controllers, otherwise just have them sign in
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let hasViewedWalkthrough = defaults.bool(forKey: "hasViewedWalkthrough")
        if !hasViewedWalkthrough {
            Amplitude.instance().logEvent("First App Lauch")
            if let onboardingVC = storyboard?.instantiateViewController(withIdentifier: "OnboardingVC") as? OnboardingVC {
                onboardingVC.presenter = self
                present(onboardingVC, animated: true, completion: nil)
            }
        }
    }
    
    // dismiss overlayed keyboard
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    // track textfield editing
    func handleTextField() {
        emailTextfield.addTarget(self, action: #selector(LoginVC.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextfield.addTarget(self, action: #selector(LoginVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // listener for textfield editing tracker
    @objc func textFieldDidChange() {
        guard let email = emailTextfield.text, !email.isEmpty, let password = passwordTextfield.text, !password.isEmpty else {
            signInBtn.setTitleColor(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1), for: .normal)
            signInBtn.isEnabled = false
            return
        }
        signInBtn.setTitleColor(UIColor.white, for: .normal)
        signInBtn.isEnabled = true
    }
    
    // authenticate and sign-in user
    @IBAction func signInBtnWasPressed(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            self.signIn()
        } else {
            self.signIn()
        }
    }
    
    // sign- in function
    func signIn() {
        let email = emailTextfield.text
        let password = passwordTextfield.text
        
        let hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = "Logging you in..."
        hud.show(in: view)
        
        if (emailTextfield.text?.isEmpty)! && (passwordTextfield.text?.isEmpty)! {
            // Display error message and shake login button
            signInBtn.wiggle()
        } else {
            AuthService.signIn(email: email!, password: password!, onSuccess: {
                hud.textLabel.text = "Hi, there! \u{1F60A}"
                 hud.dismiss(afterDelay: 4.0)
                if Auth.auth().currentUser != nil {
                    self.setupAmplitudeUserIdentity()
                    self.logAmplitudeSigninEvent()
                    self.goToMain()
                }
            }) {
                hud.textLabel.text = "Whoops, something's not right. \u{1F615}"
                hud.dismiss(afterDelay: 4.0)
                self.signInBtn.wiggle()
            }
        }
    }
    
    // go to sign-up. This should already be done though...
    @IBAction func toSignUpBtnWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpVC")
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    // enter app and go to "card deck"
    func goToMain(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()!
        self.navigationController?.pushViewController(initial, animated: true)
    }
    
    func setupAmplitudeUserIdentity() {
        API.User.observeCurrentUser(completion: { (glympsUser) in
            self.identify?.setValue(glympsUser.email, forKeyPath: "Email")
            self.identify?.setValue(glympsUser.age, forKeyPath: "Age")
            self.identify?.setValue(glympsUser.profession, forKeyPath: "Profession")
            self.identify?.setValue(glympsUser.company, forKeyPath: "Company")
            self.identify?.setValue(glympsUser.name, forKeyPath: "Name")
            self.identify?.setValue(glympsUser.gender, forKeyPath: "Gender")
            self.identify?.setValue(glympsUser.id, forKeyPath: "User ID")
            self.identify?.setValue(glympsUser.coins, forKeyPath: "Number of Glymps Coins")
            self.identify?.setValue(glympsUser.isPremium, forKeyPath: "Subscription Status")
            self.identify?.setValue(glympsUser.minAge, forKeyPath: "Minimum Preferred Age")
            self.identify?.setValue(glympsUser.maxAge, forKeyPath: "Maximum Preferred Age")
            self.identify?.setValue(glympsUser.preferedGender, forKeyPath: "Preferred Gender")
            Amplitude.instance()?.identify(self.identify)
        })
    }
    
    func logAmplitudeSigninEvent() {
        API.User.observeCurrentUser { (user) in
            let signInEventProperties: [AnyHashable : Any] = [
                "Email" : user.email ?? "",
                "Age" : user.age ?? "",
                "Profession" : user.profession ?? "",
                "Company" : user.company ?? "",
                "Name" : user.name ?? "",
                "Gender" : user.gender ?? "",
                "User ID" : user.id ?? "",
                "Coins" : user.coins ?? "",
                "Subscription Status" : user.isPremium ?? "",
                "Min Preferred Age" : user.minAge ?? "",
                "Max Preferred Age" : user.maxAge ?? "",
                "Preferred Gender" : user.preferedGender ?? ""
            ]
            Amplitude.instance().logEvent("Sign In", withEventProperties: signInEventProperties)
        }
    }
}

extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == passwordTextfield {
            textField.resignFirstResponder()
            signIn()
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let nextTag = textField.tag + 1

        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }
}
