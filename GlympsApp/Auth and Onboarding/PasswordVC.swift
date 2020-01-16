//
//  PasswordVC.swift
//  Glymps
//
//  Created by James B Morris on 5/7/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// view controller to set up new user password during onboarding
class PasswordVC: UIViewController {

    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!
    
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
    
    // prep data for next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! NameVC
        destination.userEmail = userEmail
        destination.userPassword = passwordTextfield.text!
    }
    
    // move to next view controller
    @IBAction func nextBtnWasPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        if passwordTextfield.text != "" {
            performSegue(withIdentifier: "passwordToName", sender: self)
        }
    }
    
}

extension PasswordVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
