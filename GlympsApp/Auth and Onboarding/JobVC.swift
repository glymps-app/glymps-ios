//
//  JobVC.swift
//  GlympsApp
//
//  Created by James B Morris on 5/2/20.
//  Copyright © 2020 James B Morris. All rights reserved.
//

import UIKit
import Amplitude_iOS

class JobVC: UIViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var professionTextfield: UITextField!
    
    @IBOutlet weak var companyTextfield: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var userEmail = ""
    var userPassword = ""
    var userName = ""
    var userBio = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        professionTextfield.delegate = self
        companyTextfield.delegate = self
        
        professionTextfield.returnKeyType = UIReturnKeyType.done
        companyTextfield.returnKeyType = UIReturnKeyType.done

        nextBtn.isEnabled = false
        nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        nextBtn.layer.borderWidth = 1
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(JobVC.keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)
        
        handleTextField()
    }
    
    // track textfield editing
    func handleTextField() {
        professionTextfield.addTarget(self, action: #selector(JobVC.textFieldDidChange), for: UIControl.Event.editingChanged)
        companyTextfield.addTarget(self, action: #selector(JobVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // listener for textfield editing tracker
    @objc func textFieldDidChange() {
        guard let profession = professionTextfield.text, !profession.isEmpty, let company = companyTextfield.text, !company.isEmpty else {
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
        if professionTextfield.text != "" && companyTextfield.text != "" {
            self.logAmplitudeOnboardingStepFiveOfNineCompleteJobEvent()
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let birthdayVC = storyboard.instantiateViewController(withIdentifier: "BirthdayVC") as! BirthdayVC
            birthdayVC.userEmail = userEmail
            birthdayVC.userPassword = userPassword
            birthdayVC.userName = userName
            birthdayVC.userBio = userBio
            birthdayVC.userProfession = professionTextfield.text!
            birthdayVC.userCompany = companyTextfield.text!
            self.navigationController?.pushViewController(birthdayVC, animated: true)
        }
    }
    
    func logAmplitudeOnboardingStepFiveOfNineCompleteJobEvent() {
        Amplitude.instance().logEvent("Onboarding Step Complete 5")
    }
}

extension JobVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
