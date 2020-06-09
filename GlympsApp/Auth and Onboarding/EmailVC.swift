//
//  EmailVC.swift
//  Glymps
//
//  Created by James B Morris on 5/7/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseAuth

// view controller to set up new user email during onboarding
class EmailVC: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var invalidEmailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        invalidEmailLabel.isHidden = true
        
        emailTextfield.delegate = self
        
        emailTextfield.returnKeyType = UIReturnKeyType.done
        
        nextBtn.isEnabled = false
        nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        nextBtn.layer.borderWidth = 1
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(EmailVC.keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)
        
        handleTextField()
        
    }
    
    // track textfield editing
    func handleTextField() {
        emailTextfield.addTarget(self, action: #selector(EmailVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // listener for textfield editing tracker
    @objc func textFieldDidChange() {
        
        guard let email = self.emailTextfield.text, !email.isEmpty, isValidEmail(email) != false else {
            nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
            nextBtn.isEnabled = false
            return
        }
        Auth.auth().fetchSignInMethods(forEmail: emailTextfield.text!) { (methods, err) in
            if methods == ["password"] {
                self.invalidEmailLabel.isHidden = false
                self.nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
                self.nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
                self.nextBtn.isEnabled = false
            } else {
                self.invalidEmailLabel.isHidden = true
                self.nextBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
                self.nextBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
                self.nextBtn.isEnabled = true
            }
        }
    }
    
    // dismiss keyboard
    @objc func keyboardDismiss() {
        textFieldDidChange()
        view.endEditing(true)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // move to next view controller
    @IBAction func nextBtnWasPressed(_ sender: Any) {
        if emailTextfield.text != "" {
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let passwordVC = storyboard.instantiateViewController(withIdentifier: "PasswordVC") as! PasswordVC
            passwordVC.userEmail = emailTextfield.text!
            self.navigationController?.pushViewController(passwordVC, animated: true)
        }
    }
    
}

extension EmailVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
