//
//  EmailVC.swift
//  Glymps
//
//  Created by James B Morris on 5/7/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// view controller to set up new user email during onboarding
class EmailVC: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        guard let email = emailTextfield.text, !email.isEmpty, email.isValidEmail() != false else {
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
    
    // prep for segue to next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! PasswordVC
        destination.userEmail = emailTextfield.text!
    }

    // move to next view controller
    @IBAction func nextBtnWasPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        if emailTextfield.text != "" {
            performSegue(withIdentifier: "emailToPassword", sender: self)
        }
    }
    
}
