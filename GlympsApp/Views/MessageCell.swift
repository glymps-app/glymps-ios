//
//  MessageCell.swift
//  GlympsApp
//
//  Created by James B Morris on 7/31/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation

// the message cell, or "chat bubble" on the chat controller
class MessageCell: UITableViewCell {
    
    @IBOutlet weak var bubbleView: UIView!
    
    @IBOutlet weak var bubbleViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var bubbleViewLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bubbleViewRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageDate: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var photoVideoMessageImage: UIImageView!
    
    @IBOutlet weak var videoMessagePlayButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var message: Message!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleView.layer.cornerRadius = 15
        bubbleView.clipsToBounds = true
        photoVideoMessageImage.layer.cornerRadius = 15
        photoVideoMessageImage.clipsToBounds = true
        
        messageLabel.isHidden = true
        photoVideoMessageImage.isHidden = true
        
        activityIndicator.layer.zPosition = 5
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        activityIndicator.style = .whiteLarge
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if observer != nil {
            stopObservers()
        }
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        videoMessagePlayButton.isHidden = false
        messageLabel.isHidden = true
        photoVideoMessageImage.isHidden = true
        activityIndicator.layer.zPosition = 5
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // play video message
    @IBAction func videoMessageButtonWasPressed(_ sender: Any) {
        handlePlay()
    }
    
    // observer to listen for video play/pause
    var observer: Any? = nil
    
    // play video message
    func handlePlay() {
        let videoUrl = message.videoUrl
        if videoUrl.isEmpty {
            return
        }
        if let url = URL(string: videoUrl) {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer?.frame = photoVideoMessageImage.frame
            observer = player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            videoMessagePlayButton.isHidden = true
        }
    }
    
    // remove observers when chat controller is closed
    func stopObservers() {
        player?.removeObserver(self, forKeyPath: "status")
        observer = nil
    }
    
    // observe play/pause status on video message player
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            let status: AVPlayer.Status = player!.status
            switch (status) {
            case AVPlayer.Status.readyToPlay:
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
                break
            case AVPlayer.Status.unknown, AVPlayer.Status.failed:
                break
            @unknown default:
                break
            }
        }
    }
    
    // function for setting up cell from inbox controller
    func configureCell(uid: String, message: Message) {
        self.message = message
        let text = message.text
        if !text.isEmpty {
            messageLabel.isHidden = false
            messageLabel.text = message.text
            
            let widthValue = text.estimateFrameForText(text).width + 40
            
            if widthValue < 75 {
                bubbleViewWidth.constant = 75
            } else {
                bubbleViewWidth.constant = widthValue
            }
        } else {
            photoVideoMessageImage.isHidden = false
            photoVideoMessageImage.loadImage(message.imageUrl)
            bubbleViewWidth.constant = 250
        }
        
        if uid == message.from {
            bubbleView.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
            messageLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            bubbleViewRightConstraint.constant = 8
            bubbleViewLeftConstraint.constant = UIScreen.main.bounds.width - bubbleViewRightConstraint.constant - bubbleViewWidth.constant
        } else {
            bubbleView.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
            messageLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            bubbleViewLeftConstraint.constant = 8
            bubbleViewRightConstraint.constant = UIScreen.main.bounds.width - bubbleViewLeftConstraint.constant - bubbleViewWidth.constant
        }
        
        let date = Date(timeIntervalSince1970: message.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        messageDate.text = dateString
    }
    
    // setup timestamp for message
    func timeAgoSinceDate(_ date:Date, currentDate:Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){ return "1 year ago"
            } else { return "Last year" }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){ return "1 month ago"
            } else { return "Last month" }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){ return "1 week ago"
            } else { return "Last week" }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){ return "1 day ago"
            } else { return "Yesterday" }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){ return "1 hour ago"
            } else { return "An hour ago" }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){ return "1 minute ago"
            } else { return "A minute ago" }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else { return "Just now" }
    }

    // not used
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}

extension String {
    
    // sizing function for adjusting bubble size to amount of text
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 17)!], context: nil)
    }
}

extension UIImageView {
    
    // function for caching message images
    func loadImage(_ urlString: String?, onSuccess: ((UIImage) -> Void)? = nil) {
        self.image = UIImage()
        guard let string = urlString else { return }
        guard let url = URL(string: string) else { return }
        self.sd_setImage(with: url) { (image, error, type, url) in
            if onSuccess != nil, error == nil {
                onSuccess!(image!)
            }
        }
    }
}
