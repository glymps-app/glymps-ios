//
//  BioVC.swift
//  GlympsApp
//
//  Created by James B Morris on 5/2/20.
//  Copyright © 2020 James B Morris. All rights reserved.
//

import UIKit
import Amplitude_iOS

class BioVC: UIViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var bioTextfield: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var userEmail = ""
    var userPassword = ""
    var userName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        bioTextfield.delegate = self
        
        bioTextfield.returnKeyType = UIReturnKeyType.done

        nextBtn.isEnabled = false
        nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        nextBtn.layer.borderWidth = 1
        
        bioTextfield.layer.borderColor = #colorLiteral(red: 0, green: 0.7123068571, blue: 1, alpha: 1)
        nextBtn.layer.borderWidth = 1
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(BioVC.keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)
        
        handleTextField()
    }
    
    // track textfield editing
    func handleTextField() {
        bioTextfield.addTarget(self, action: #selector(BioVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // listener for textfield editing tracker
    @objc func textFieldDidChange() {
        guard let bio = bioTextfield.text, !bio.isEmpty else {
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
    
    @IBAction func nextBtnWasPressed(_ sender: Any) {
        if bioTextfield.text != "" {
            self.logAmplitudeOnboardingStepFourOfNineCompleteBioEvent()
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let jobVC = storyboard.instantiateViewController(withIdentifier: "JobVC") as! JobVC
            jobVC.userEmail = userEmail
            jobVC.userPassword = userPassword
            jobVC.userName = userName
            jobVC.userBio = bioTextfield.text!
            self.navigationController?.pushViewController(jobVC, animated: true)
        }
    }
    
    func logAmplitudeOnboardingStepFourOfNineCompleteBioEvent() {
        Amplitude.instance().logEvent("Onboarding Step 4/9 Complete (Bio)")
    }

}

extension BioVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
