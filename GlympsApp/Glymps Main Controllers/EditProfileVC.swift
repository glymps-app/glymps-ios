//
//  EditProfileVC.swift
//  GlympsApp
//
//  Created by James B Morris on 6/17/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import JGProgressHUD

// screen for user to edit their Glymps profile
class EditProfileVC: UITableViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var profileImage1: UIImageView!
    
    @IBOutlet weak var profileImage2: UIImageView!
    
    @IBOutlet weak var removeProfileImage2Btn: UIButton!
    
    @IBOutlet weak var profileImage3: UIImageView!
    
    @IBOutlet weak var removeProfileImage3Btn: UIButton!

    @IBOutlet weak var bioTextfield: UITextField!
    
    @IBOutlet weak var genderTextfield: UITextField!
    
    @IBOutlet weak var nameTextfield: UITextField!
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var ageTextfield: UITextField!
    
    @IBOutlet weak var professionTextfield: UITextField!
    
    @IBOutlet weak var companyTextfield: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    var selectedProfileImage: UIImage?
    
    // flags to determine how many profile images they want to upload/remove
    var flag1 = true
    var flag2 = true
    var flag3 = true
    
    let genders = ["Male", "Female"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage1.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        profileImage1.layer.borderWidth = 1
        profileImage2.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        profileImage2.layer.borderWidth = 1
        profileImage3.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        profileImage3.layer.borderWidth = 1
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(EmailVC.keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(EditProfileVC.handleSelectProfileImageView1))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(EditProfileVC.handleSelectProfileImageView2))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(EditProfileVC.handleSelectProfileImageView3))
    
        profileImage1.addGestureRecognizer(tapGesture1)
        profileImage2.addGestureRecognizer(tapGesture2)
        profileImage3.addGestureRecognizer(tapGesture3)
        
        removeProfileImage2Btn.layer.zPosition = 3
        removeProfileImage3Btn.layer.zPosition = 3
        
        if profileImage2 != nil {
            removeProfileImage2Btn.isEnabled = true
            removeProfileImage2Btn.isHidden = false
        }
        if profileImage3 != nil {
            removeProfileImage3Btn.isEnabled = true
            removeProfileImage3Btn.isHidden = false
        }
        
        createPicker()
        createToolbar()
        
        handleTextField()

        fetchCurrentUser()
    }
    
    // get current user
    func fetchCurrentUser() {
        API.User.observeCurrentUser { (user) in
            if let photoUrlString = user.profileImages {
                if let photoUrl1 = URL(string: photoUrlString.first ?? "") {
                    self.profileImage1.sd_setImage(with: photoUrl1)
                }
                let index1 = 1
                let index2 = 2
                
                if index1 >= 0 && index1 < photoUrlString.count {
                    let photoUrl2 = URL(string: photoUrlString[index1])
                    self.profileImage2.sd_setImage(with: photoUrl2)
                }
                
                if index2 >= 0 && index2 < photoUrlString.count {
                    let photoUrl3 = URL(string: photoUrlString[index2])
                    self.profileImage3.sd_setImage(with: photoUrl3)
                }
            }
            self.bioTextfield.text = user.bio
            self.genderTextfield.text = user.gender
            self.nameTextfield.text = user.name
            self.emailTextfield.text = user.email
            self.ageTextfield.text = "\(user.age!)"
            self.professionTextfield.text = user.profession
            self.companyTextfield.text = user.company
        }
    }
    
    // create a picker so user can choose profile images
    func createPicker() {
    
        let picker = UIPickerView()
        picker.delegate = self
    
        genderTextfield.inputView = picker
    
        picker.backgroundColor = .white
        
    }
    
    // create "done" toolbar so user can dismiss picker
    func createToolbar() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        toolbar.barTintColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        toolbar.tintColor = .white
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditProfileVC.keyboardDismiss))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        genderTextfield.inputAccessoryView = toolbar
        
    }
    
    // handle selection of first profile image
    @objc func handleSelectProfileImageView1() {
        flag1 = true
        flag2 = false
        flag3 = false
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    // handle selection of second profile image
    @objc func handleSelectProfileImageView2() {
        flag1 = false
        flag2 = true
        flag3 = false
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    // handle selection of third profile image
    @objc func handleSelectProfileImageView3() {
        flag1 = false
        flag2 = false
        flag3 = true
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    // track textfield editing
    func handleTextField() {
        emailTextfield.addTarget(self, action: #selector(EditProfileVC.textFieldDidChange), for: UIControl.Event.editingChanged)
        genderTextfield.addTarget(self, action: #selector(EditProfileVC.textFieldDidChange), for: UIControl.Event.editingChanged)
        nameTextfield.addTarget(self, action: #selector(EditProfileVC.textFieldDidChange), for: UIControl.Event.editingChanged)
        ageTextfield.addTarget(self, action: #selector(EditProfileVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // listener for textfield editing tracker
    @objc func textFieldDidChange() {
        guard let gender = genderTextfield.text, !gender.isEmpty, let name = nameTextfield.text, !name.isEmpty, let email = emailTextfield.text, !email.isEmpty, email.isValidEmail(), let age = ageTextfield.text, !age.isEmpty, (Int(age)! >= 18) != false else {
            saveBtn.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
            saveBtn.layer.backgroundColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
            saveBtn.isEnabled = false
            return
        }
        saveBtn.setTitleColor(#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), for: .normal)
        saveBtn.layer.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        saveBtn.isEnabled = true
    }
    
    // dismiss keyboard
    @objc func keyboardDismiss() {
        textFieldDidChange()
        view.endEditing(true)
    }
    
    // go back to main profile screen
    @IBAction func backBtnWasPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC")
        self.present(profileVC, animated: true, completion: nil)
    }
    
    // remove second profile image
    @IBAction func removeProfileImage2BtnWasPressed(_ sender: Any) {
        profileImage2.image = nil
        removeProfileImage2Btn.isEnabled = false
        removeProfileImage2Btn.isHidden = true
    }
    
    // remove third profile image
    @IBAction func removeProfileImage3BtnWasPressed(_ sender: Any) {
        profileImage3.image = nil
        removeProfileImage3Btn.isEnabled = false
        removeProfileImage3Btn.isHidden = true
    }
    
    // save profile attributes (if edited)
    @IBAction func saveBtnWasPressed(_ sender: Any) {
        let hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = "Saving your info..."
        hud.show(in: view)
        
        // arrange selected profile images into list and prep for storage
        var imageDatas: [Data] = []
        
        if let profileImg1 = self.profileImage1.image, let imageData1 = profileImg1.jpegData(compressionQuality: 0.1) {
            
            imageDatas.append(imageData1)
            
            if let imageData2 = profileImage2.image?.jpegData(compressionQuality: 0.1) {
                imageDatas.append(imageData2)
            }
            if let imageData3 = profileImage3.image?.jpegData(compressionQuality: 0.1) {
                imageDatas.append(imageData3)
            }
            
            // update current user's information on Firebase
            AuthService.updateUserInfo(name: nameTextfield.text!, gender: genderTextfield.text!, age: Int(ageTextfield.text!)!, email: emailTextfield.text!, bio: bioTextfield.text!, profession: professionTextfield.text!, company: companyTextfield.text!, imageData: imageDatas, onSuccess: {
                
                hud.textLabel.text = "All done! \u{1F389}"
                hud.dismiss(afterDelay: 4.0)
                //self.delegate?.updateUserInfo()
            }) {
                hud.textLabel.text = "Whoops, something's not right. \u{1F615}"
                hud.dismiss(afterDelay: 4.0)
            }
        }
        
        
    }
    
    
    
}

// setup image pickers so user can select profile images
extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            if flag1 {
                selectedProfileImage = image
                profileImage1.image = image
            } else if flag2 {
                selectedProfileImage = image
                profileImage2.image = image
                
                removeProfileImage2Btn.isEnabled = true
                removeProfileImage2Btn.isHidden = false
            } else if flag3 {
                selectedProfileImage = image
                profileImage3.image = image
                
                removeProfileImage3Btn.isEnabled = true
                removeProfileImage3Btn.isHidden = false
            }
        }
        dismiss(animated: true, completion: nil)
        
    }
}

// setup pickers for profile images
extension EditProfileVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // number of sections in row
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    // title (male, female)
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    // attach gender to display view above if male/female selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextfield.text = genders[row]
    }
    
    // allocate selected gender to appropriate display view above
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label = UILabel()
        
        if genderTextfield.text == "Male" {
            genderTextfield.text = genders[0]
        }
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir-Next", size: 17)
        
        label.text = genders[row]
        
        return label
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
