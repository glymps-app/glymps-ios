//
//  ChatVC.swift
//  GlympsApp
//
//  Created by James B Morris on 7/31/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import LBTATools
import PushNotifications

// chat screen for current user to message another user
class ChatVC: UIViewController {
    
    var userId: String?
    var username: String?
    var currentUsername: String?
    var currentUser: User?
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var userInfoBtn: UIButton!
    
    @IBOutlet weak var declineBtn: UIButton!
    
    @IBOutlet weak var navBar: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var constrainToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var mediaBtn: UIButton!
    
    @IBOutlet weak var inputTextView: UITextView!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    var placeholderLabel = UILabel()
    
    var picker = UIImagePickerController()
    
    var messages = [Message]()
    
    var cardView: CardView?
    
    var messagesVC: MessagesVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(currentUser ?? "NO CURRENT USER")
        print(currentUsername ?? "NO CURRENT USERNAME")
        
        sendBtn.isEnabled = true
        
        picker.delegate = self
        
        setupUI()
        setupBottomBar()
        setupTableView()
        observeMessages()
        setupUserView()
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        navBar.setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        bottomView.setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: -10), color: .init(white: 0, alpha: 0.3))

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let id = self.userId {
                print(id)
            }
        }
        
        // auto scroll to bottom (most recent messages) of chat when view loads
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if self.messages.count > 0 {
                self.tableView.scrollToRow(at: IndexPath.init(row: self.messages.count - 1, section: 0), at: .none, animated: true)
            }
        })
    }
    
    // dismiss keyboard
    @objc func keyboardDismiss() {
        
        view.endEditing(true)
        
    }
    
    // bind keyboard to bottom of messages tableViews
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.constrainToBottom.constant = -(keyboardFrame?.height)!
            self.tableViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        if placeholderLabel.isHidden == false {
            placeholderLabel.isHidden = true
        }
    }
    
    // unbind keyboard from bottom of messages tableView
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.constrainToBottom.constant = 0
            self.tableViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        if inputTextView.text == "" {
            placeholderLabel.isHidden = false
        }
    }
    
    // setup other user's detail view
    func setupUserView() {
        
        API.User.observeUsers(withId: userId!) { (user) in
            self.username = user.name!
            let gradientView = GlympsGradientView()
            let barsStackView = UIStackView()
             gradientView.layer.opacity = 0.5
            let cardView = CardView(frame: .zero)
            cardView.images = user.profileImages
            if let photoUrlString = user.profileImages {
                let photoUrl = URL(string: photoUrlString[0])
                cardView.imageView.sd_setImage(with: photoUrl)
            }
            (0..<user.profileImages!.count).forEach { (_) in
                let barView = UIView()
                barView.backgroundColor = UIColor(white: 0, alpha: 0.1)
                barView.layer.cornerRadius = barView.frame.size.height / 2
                barsStackView.addArrangedSubview(barView)
                barsStackView.arrangedSubviews.first?.backgroundColor = .white
            }
            
            let nametraits = [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]
            var nameFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family: "Avenir Next"])
            nameFontDescriptor = nameFontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: nametraits])
            
            let agetraits = [UIFontDescriptor.TraitKey.weight: UIFont.Weight.light]
            var ageFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family: "Avenir Next"])
            ageFontDescriptor = ageFontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: agetraits])
            
            let jobtraits = [UIFontDescriptor.TraitKey.weight: UIFont.Weight.light]
            var jobFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family: "Avenir Next"])
            jobFontDescriptor = jobFontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: jobtraits])
            
            let attributedText = NSMutableAttributedString(string: user.name!, attributes: [.font: UIFont(descriptor: nameFontDescriptor, size: 30)])
            attributedText.append(NSAttributedString(string: " \(user.age!)", attributes: [.font: UIFont(descriptor: ageFontDescriptor, size: 24)]))
            if user.profession != "" && user.company != "" {
                attributedText.append(NSAttributedString(string: "\n\(user.profession!) @ \(user.company!)", attributes: [.font: UIFont(descriptor: jobFontDescriptor, size: 20)]))
            }
            
            cardView.informationLabel.attributedText = attributedText
            
            cardView.addSubview(gradientView)
            cardView.addSubview(barsStackView)
            cardView.stackView = barsStackView
            cardView.userId = self.userId
            barsStackView.anchor(top: cardView.topAnchor, leading: cardView.leadingAnchor, bottom: nil, trailing: cardView.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
            barsStackView.spacing = 4
            barsStackView.distribution = .fillEqually
            
            self.cardView = cardView
        }
        
    }
    
    // setup other user's info
    func setupUI() {
        
        API.User.observeUsers(withId: userId!) { (user) in
            
            self.usernameLabel.text = user.name
            self.profileImage.sd_setImage(with: URL(string: user.profileImages!.first!))
        }
    }
    
    // setup message bar on bottom
    func setupBottomBar() {
        
        inputTextView.delegate = self
        
        placeholderLabel.isHidden = false
        
        let placeholderX: CGFloat = self.view.frame.size.width / 75
        let placeholderY: CGFloat = 0
        let placeholderWidth: CGFloat = inputTextView.bounds.width - placeholderX
        let placeholderHeight: CGFloat = inputTextView.bounds.height
        
        placeholderLabel.frame = CGRect(x: placeholderX, y: placeholderY, width: placeholderWidth, height: placeholderHeight)
        
        placeholderLabel.text = "Write a message..."
        placeholderLabel.font = UIFont(name: "Avenir-Medium", size: 17)
        placeholderLabel.textColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        placeholderLabel.textAlignment = .left
        
        inputTextView.addSubview(placeholderLabel)
    }
    
    // setup messages layout
    func setupTableView() {
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    // get all conversation messages
    func observeMessages() {
        
        API.Messages.retrieveMessages(from: userId!, to: API.User.CURRENT_USER!.uid) { (message) in
            self.messages.append(message)
            self.sortMessages()
        }
        
        API.Messages.retrieveMessages(from: API.User.CURRENT_USER!.uid, to: userId!) { (message) in
            self.messages.append(message)
            self.sortMessages()
        }
    }
    
    // sort messages by date
    func sortMessages() {
        messages = messages.sorted(by: { $0.date < $1.date })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // go back to inbox
    @IBAction func backBtnWasPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessagesVC")
        self.present(messagesVC, animated: true, completion: nil)
    }
    
    // go to user detail view to see other user's information
    @IBAction func userInfoBtnWasPressed(_ sender: Any) {
        let userDetailsController = UserDetailsVC()
        userDetailsController.userId = self.userId
        userDetailsController.cardView = self.cardView
        self.present(userDetailsController, animated: true, completion: nil)
    }
    
    // decline and block user for 24 hours, and dismiss chat view controller
    @IBAction func declineBtnWasPressed(_ sender: Any) {
        // remove user from current user message requests and matches
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let blockOptionsVC = storyboard.instantiateViewController(withIdentifier: "BlockOptionsVC") as! BlockOptionsVC
        blockOptionsVC.userId = self.userId
        blockOptionsVC.chatVC = self
        self.present(blockOptionsVC, animated: true, completion: nil)
    }
    
    // display picker to send photo or video message
    @IBAction func mediaBtnWasPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Glymps", message: "Please select a source:", preferredStyle: UIAlertController.Style.actionSheet)
        let camera = UIAlertAction(title: "Take a picture", style: UIAlertAction.Style.default) { (_) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.picker.sourceType = .camera
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Option unavailable.")
            }
        }
        let video = UIAlertAction(title: "Take a video", style: UIAlertAction.Style.default) { (_) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.picker.sourceType = .camera
                self.picker.mediaTypes = [String(kUTTypeMovie)]
                self.picker.videoExportPreset = AVAssetExportPresetPassthrough
                self.picker.videoMaximumDuration = 30
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Option unavailable.")
            }
        }
        let library = UIAlertAction(title: "Choose an image or video", style: UIAlertAction.Style.default) { (_) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                self.picker.sourceType = .photoLibrary
                self.picker.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Option unavailable.")
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(video)
        alert.addAction(library)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // send message (text, photo, or video)
    @IBAction func sendBtnWasPressed(_ sender: Any) {
        if messages.count == 1 && messages.first?.from == API.User.CURRENT_USER!.uid {
            mediaBtn.isEnabled = false
            sendBtn.isEnabled = false
        } else if messages.count == 2 && messages.last?.from == API.User.CURRENT_USER!.uid {
            mediaBtn.isEnabled = true
            sendBtn.isEnabled = true
            if let text = inputTextView.text, text != "" {
                inputTextView.text = ""
                self.textViewDidChange(inputTextView)
                sendToFirebase(dict: ["text" : text as Any])
            }
        } else if messages.count == 2 && messages.last?.from == self.userId {
            mediaBtn.isEnabled = true
            sendBtn.isEnabled = true
            if let text = inputTextView.text, text != "" {
                inputTextView.text = ""
                self.textViewDidChange(inputTextView)
                sendToFirebase(dict: ["text" : text as Any])
            }
        } else if messages.count >= 2 {
            // continued messaging enabled (depends on premium status)
            mediaBtn.isEnabled = true
            sendBtn.isEnabled = true
            if messages.filter({ $0.from == API.User.CURRENT_USER!.uid }).count >= 5 && self.currentUser?.isPremium == false {
                mediaBtn.isEnabled = false
                sendBtn.isEnabled = false
            }else if let text = inputTextView.text, text != "" {
                inputTextView.text = ""
                self.textViewDidChange(inputTextView)
                sendToFirebase(dict: ["text" : text as Any])
                
                sendMessageNotification(message: "\(self.currentUsername!) messaged you.")
            }
        } else {
            mediaBtn.isEnabled = true
            sendBtn.isEnabled = true
            if let text = inputTextView.text, text != "" {
                inputTextView.text = ""
                self.textViewDidChange(inputTextView)
                sendToFirebase(dict: ["text" : text as Any])
            }
        }
    }
    
    // store messages on Firebase
    func sendToFirebase(dict: Dictionary<String, Any>) {
        
        let date: Double = Date().timeIntervalSince1970
        var value = dict
        value["from"] = API.User.CURRENT_USER?.uid
        value["to"] = self.userId
        value["date"] = date
        value["read"] = true
        
        API.Messages.sendMessage(from: API.User.CURRENT_USER!.uid, to: self.userId!, value: value)
    }
    
    let matchView = MatchView()
    
    // display animated match view!
    func presentMatchView(uid: String) {
        
        API.Inbox.removeMessageRequest(uid: self.userId!)
        UserDefaults.standard.removeObject(forKey: "\(self.userId!):request")
        
        API.Inbox.saveMatch(uid: uid)
        
        matchView.userId = uid
        matchView.chatVC = self
        matchView.username = self.username
        view.addSubview(matchView)
        matchView.fillSuperview()
        
        sendMatchNotification(message: "\(self.currentUsername!) matched with you!")
        
        UserDefaults.standard.set(true, forKey: "\(self.userId!)")
    }
    
    // send new request to message push notification
    func sendRequestNotification(message: String) {
        
        UserDefaults.standard.set(true, forKey: "\(self.userId!):request")
        
        // send Pusher Notification for Message Request
        messageUser(toUser: self.userId!, message: message)
        
    }
    
    // send new match push notification
    func sendMatchNotification(message: String) {
        
        UserDefaults.standard.set(true, forKey: "\(self.userId!):match")
        
        // send Pusher Notification for Match
        messageUser(toUser: self.userId!, message: message)
        
    }
    
    // send new message push notification
    func sendMessageNotification(message: String) {
        
        // send Pusher Notification for Messages
        messageUser(toUser: self.userId!, message: message)
        
    }
    
    
    // send a notification
    func messageUser(toUser: String, message: String) {
        let notificationsURL = URL(string: "https://glymps-pusher-notifications.herokuapp.com/pusher/send-message")!
        var request = URLRequest(url: notificationsURL)
        request.httpBody = "user_id=\(toUser)&content=\(message)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            if (error != nil) {
                print("Error: \(error?.localizedDescription ?? "")")
            } else {
                print("Success!")
            }
            }.resume()
    }
    
}

// handle textfield editing tracking
extension ChatVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let spacing = CharacterSet.whitespacesAndNewlines
        if !textView.text.trimmingCharacters(in: spacing).isEmpty {
            let text = textView.text.trimmingCharacters(in: spacing)
            sendBtn.isEnabled = true
            sendBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
            placeholderLabel.isHidden = true
        } else {
            sendBtn.isEnabled = false
            sendBtn.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            placeholderLabel.isHidden = false
        }
    }
}

// setup image picker for selecting photos/videos to send
extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleVideoSelectedUrl(videoUrl)
        } else {
            handleImageSelectedUrl(info)
        }
    }
    
    func handleVideoSelectedUrl(_ url: URL) {
        // save video
        let videoName = NSUUID().uuidString
        API.Messages.saveVideoMessage(url: url, id: videoName, onSuccess: { (anyValue) in
            if let dict = anyValue as? [String : Any] {
                self.sendToFirebase(dict: dict)
            }
        }) { (errorMessage) in
            
        }
        
        self.picker.dismiss(animated: true, completion: nil)
    }
    
    func handleImageSelectedUrl(_ info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = imageSelected
        }
        
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = imageOriginal
        }
        
        // save photo
        let imageName = NSUUID().uuidString
        API.Messages.savePhotoMessage(image: selectedImageFromPicker, id: imageName, onSuccess: { (anyValue) in
            if let dict = anyValue as? [String : Any] {
                self.sendToFirebase(dict: dict)
            }
        }) { (errorMessage) in
            
        }
        
        self.picker.dismiss(animated: true, completion: nil)
    }
    
}

// configure background tableView images
extension ChatVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // motivate user to send a message :)
        if messages.count == 0 {
            tableView.setEmptyView(title: "No messages yet.", message: "Don't be shy! Type something and press that send button!", image: UIImage())
            self.sendBtn.isEnabled = true
            self.mediaBtn.isEnabled = true
            tableView.separatorStyle = .none
            // disable sending until other user messages back and matches
        } else if messages.count == 1 && messages.first?.from == API.User.CURRENT_USER!.uid {
            tableView.setEmptyView(title: "Message request sent.", message: "If they reply, you'll be matched!", image: UIImage())
            if !UserDefaults.standard.bool(forKey: "\(self.userId!):request") {
                API.Inbox.saveRequest(uid: self.userId!)
                // send a notification
                sendRequestNotification(message: "\(self.currentUsername!) requested to message you.")
            }
            self.mediaBtn.isEnabled = false
            self.sendBtn.isEnabled = false
            tableView.separatorStyle = .none
            // present match view!
        } else if (messages.count == 2) || (messages.count >= 2 && messages.filter({ $0.from == API.User.CURRENT_USER?.uid }).count == 1) {
           if !UserDefaults.standard.bool(forKey: "\(self.userId!)") {
                self.view.endEditing(true)
                self.presentMatchView(uid: self.userId!)
            }
            tableView.separatorStyle = .none
        } else if messages.filter({ $0.from == API.User.CURRENT_USER!.uid }).count >= 5 && self.currentUser?.isPremium == false {
            // disable messaging until current user becomes Premium user
            tableView.setEmptyView(title: "Messaging limit reached.", message: "Activate Glymps Premium to continue.", image: UIImage())
            self.mediaBtn.isEnabled = false
            self.sendBtn.isEnabled = false
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .none
            tableView.restore()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if self.messages.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath.init(row: self.messages.count - 1, section: 0), at: .none, animated: true)
                }
            })
        }
        return messages.count
    }
    
    // configure message cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        cell.videoMessagePlayButton.isHidden = messages[indexPath.row].videoUrl == ""
        cell.configureCell(uid: API.User.CURRENT_USER!.uid, message: messages[indexPath.row])
        
        return cell
    }
    
    // set height/width for message cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        let message = messages[indexPath.row]
        let text = message.text
        if !text.isEmpty {
            height = text.estimateFrameForText(text).height + 45
        }
        let heightMessage = message.height
        let widthMessage = message.width
        if heightMessage != 0, widthMessage != 0 {
            height = CGFloat((heightMessage / widthMessage) * 250)
        }
        return height
    }
    
}
