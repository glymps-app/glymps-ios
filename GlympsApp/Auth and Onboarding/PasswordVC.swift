//
//  PasswordVC.swift
//  Glymps
//
//  Created by James B Morris on 5/7/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import Amplitude_iOS

// view controller to set up new user password during onboarding
class PasswordVC: UIViewController {

    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    var userEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextfield.delegate = self
        
        passwordTextfield.returnKeyType = UIReturnKeyType.done

        nextBtn.isEnabled = false
        nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        nextBtn.layer.borderWidth = 1
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(PasswordVC.keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)
        
        handleTextField()

    }
    
    // track textfield editing
    func handleTextField() {
        passwordTextfield.addTarget(self, action: #selector(PasswordVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // listener for textfield editing tracker, make sure user password is more than 8 characters
    @objc func textFieldDidChange() {
        guard let password = passwordTextfield.text, !password.isEmpty, password.count >= 8 else {
            nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
            nextBtn.isEnabled = false
            return
        }
        nextBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
        nextBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        nextBtn.isEnabled = true
    }
    
    // dismiss keyboard
    @objc func keyboardDismiss() {
        textFieldDidChange()
        view.endEditing(true)
    }
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // move to next view controller
    @IBAction func nextBtnWasPressed(_ sender: Any) {
        if passwordTextfield.text != "" {
            self.logAmplitudeOnboardingStepTwoOfNineCompletePasswordEvent()
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let nameVC = storyboard.instantiateViewController(withIdentifier: "NameVC") as! NameVC
            nameVC.userEmail = userEmail
            nameVC.userPassword = passwordTextfield.text!
            self.navigationController?.pushViewController(nameVC, animated: true)
        }
    }
    
    func logAmplitudeOnboardingStepTwoOfNineCompletePasswordEvent() {
        Amplitude.instance().logEvent("Onboarding Step Complete 2")
    }
    
}

extension PasswordVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
