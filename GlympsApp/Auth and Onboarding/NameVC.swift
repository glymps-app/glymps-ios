//
//  NameVC.swift
//  Glymps
//
//  Created by James B Morris on 5/7/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import Amplitude_iOS

// view controller to set up new user name during onboarding
class NameVC: UIViewController {
    
    @IBOutlet weak var nameTextfield: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    var userEmail = ""
    var userPassword = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextfield.delegate = self
        
        nameTextfield.returnKeyType = UIReturnKeyType.done

        nextBtn.isEnabled = false
        nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        nextBtn.layer.borderWidth = 1
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(NameVC.keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)
        
        handleTextField()
    }
    
    // track textfield editing
    func handleTextField() {
        nameTextfield.addTarget(self, action: #selector(NameVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // listener for textfield editing tracker
    @objc func textFieldDidChange() {
        guard let name = nameTextfield.text, !name.isEmpty else {
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
        if nameTextfield.text != "" {
            self.logAmplitudeOnboardingStepThreeOfNineCompleteNameEvent()
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let bioVC = storyboard.instantiateViewController(withIdentifier: "BioVC") as! BioVC
            bioVC.userEmail = userEmail
            bioVC.userPassword = userPassword
            bioVC.userName = nameTextfield.text!
            self.navigationController?.pushViewController(bioVC, animated: true)
        }
    }
    
    func logAmplitudeOnboardingStepThreeOfNineCompleteNameEvent() {
        Amplitude.instance().logEvent("Onboarding Step 3/9 Complete (Name)")
    }

}

extension NameVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
