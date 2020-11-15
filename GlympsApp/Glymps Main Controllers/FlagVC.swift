//
//  FlagVC.swift
//  GlympsApp
//
//  Created by James B Morris on 4/7/20.
//  Copyright © 2020 James B Morris. All rights reserved.
//

import UIKit
import Amplitude_iOS

class FlagVC: UIViewController {
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var detailsTextfield: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var currentUsername: String?
    var username: String?
    var blockOptionsVC: BlockOptionsVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logAmplitudeReportUserViewEvent()

        detailsTextfield.delegate = self
        detailsTextfield.returnKeyType = UIReturnKeyType.done
        
        submitBtn.isEnabled = false
        submitBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(FlagVC.keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)
        
        handleTextField()
        setupLabel()
    }
    
    func handleTextField() {
        detailsTextfield.addTarget(self, action: #selector(FlagVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // listener for textfield editing tracker
    @objc func textFieldDidChange() {
        
        guard let details = self.detailsTextfield.text, !details.isEmpty else {
            submitBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            submitBtn.isEnabled = false
            return
        }
        self.submitBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        self.submitBtn.isEnabled = true
    }
    
    // dismiss keyboard
    @objc func keyboardDismiss() {
        textFieldDidChange()
        view.endEditing(true)
    }
    
    func setupLabel() {
        API.User.observeCurrentUser { (user) in
            self.detailsLabel.text = "Hi \(user.name!)! Thank you for making the Glymps community a better place and reporting prohibited content and behavior. Please enter some details below on why you are flagging \(self.username!). All details you provide are anonymous:"
        }
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func submitBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            self.blockOptionsVC?.flagAction(reason: self.detailsTextfield.text!)
        }
    }
    
    func logAmplitudeReportUserViewEvent() {
        Amplitude.instance().logEvent("Report User View")
    }
    

}

extension FlagVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
