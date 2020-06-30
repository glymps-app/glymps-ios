//
//  CardView.swift
//  Glymps
//
//  Created by James B Morris on 4/30/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import SDWebImage

protocol MoreInfoDelegate: class {
    func goToMoreInfo(userId: String, cardView: CardView)
}

// A card in the "card deck" that displays each User's information
class CardView: UIView {

    var imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"))

    var informationLabel = UILabel()

    var images: [String]?

    var userId: String?

    var stackView: UIStackView?

    var moreInfoButton: UIButton?

    var messageUserButton: UIButton?

    var cycleLeftButton: UIButton?

    var cycleRightButton: UIButton?

    weak var moreInfoDelegate: MoreInfoDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        // round image
        layer.cornerRadius = 15
        clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.fillSuperview()

        // layout label
        addSubview(informationLabel)
        informationLabel.numberOfLines = 0
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        informationLabel.text = ""
        informationLabel.textColor = .white
        informationLabel.layer.zPosition = 1

        // add tap gesture to cycle through profile images
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)

    }

    var imageIndex = 0

    // cycle through profile images, determines whether to cycle forward or backward bassd on touch location, and then setup image accordingly
    @objc func handleTap(gesture: UITapGestureRecognizer) {

        let tapLocation = gesture.location(in: imageView)
        let shouldAdvanceNextPhoto = (tapLocation.x > ((frame.width / 2) + 120)) && (tapLocation.y < moreInfoButton!.frame.origin.y - 10) && (tapLocation.y > (messageUserButton?.frame.origin.y)! + 50) ? true : false

        if shouldAdvanceNextPhoto {
            imageIndex = min(imageIndex + 1, images!.count - 1)

            if (imageIndex == 0) && (images!.count > 1) {
                cycleLeftButton?.isHidden = true
                cycleLeftButton?.isEnabled = false
                cycleRightButton?.isHidden = false
                cycleRightButton?.isEnabled = true
            } else if (imageIndex == 1) && (images!.count > 2) {
                cycleLeftButton?.isHidden = false
                cycleLeftButton?.isEnabled = true
                cycleRightButton?.isHidden = false
                cycleRightButton?.isEnabled = true
            } else if (imageIndex == 1) && (images!.count == 2){
                cycleLeftButton?.isHidden = false
                cycleLeftButton?.isEnabled = true
                cycleRightButton?.isHidden = true
                cycleRightButton?.isEnabled = false
            } else if (imageIndex == 2) && (images!.count > 2){
                cycleLeftButton?.isHidden = false
                cycleLeftButton?.isEnabled = true
                cycleRightButton?.isHidden = true
                cycleRightButton?.isEnabled = false
            }
        } else if (tapLocation.x < ((frame.width / 2) - 120)) && (tapLocation.y < moreInfoButton!.frame.origin.y - 10) && (tapLocation.y > (messageUserButton?.frame.origin.y)! + 50) {
            imageIndex = max(0, imageIndex - 1)

            if (imageIndex == 0) && (images!.count > 1) {
                cycleLeftButton?.isHidden = true
                cycleLeftButton?.isEnabled = false
                cycleRightButton?.isHidden = false
                cycleRightButton?.isEnabled = true
            } else if (imageIndex == 1) && (images!.count > 2) {
                cycleLeftButton?.isHidden = false
                cycleLeftButton?.isEnabled = true
                cycleRightButton?.isHidden = false
                cycleRightButton?.isEnabled = true
            } else if (imageIndex == 1) && (images!.count == 2){
                cycleLeftButton?.isHidden = false
                cycleLeftButton?.isEnabled = true
                cycleRightButton?.isHidden = true
                cycleRightButton?.isEnabled = false
            } else if (imageIndex == 2) && (images!.count > 2){
                cycleLeftButton?.isHidden = false
                cycleLeftButton?.isEnabled = true
                cycleRightButton?.isHidden = true
                cycleRightButton?.isEnabled = false
            }
        } else if (tapLocation.y < moreInfoButton!.frame.origin.y - 10) && (tapLocation.y > (messageUserButton?.frame.origin.y)! + 50) {
            moreInfoDelegate?.goToMoreInfo(userId: self.userId ?? "", cardView: self)
        }

        let imageUrls = images![imageIndex]

        let photoUrl = URL(string: imageUrls)
        imageView.sd_setImage(with: photoUrl)

        self.subviews.forEach { (view) in
            let sv = stackView
            if view == sv {
                sv?.arrangedSubviews.forEach({ (v) in
                    v.backgroundColor = UIColor(white: 0, alpha: 0.1)
                })
                sv!.arrangedSubviews[imageIndex].backgroundColor = .white
            }
        }
    }

    // default view encoder
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

}

extension UIColor {
    static let glympsPurple = UIColor(red: 0.65, green: 0.55, blue: 0.77, alpha: 1)
    static let glympsGreen = UIColor(red: 0.34, green: 0.73, blue: 0.67, alpha: 1)
    static let glympsBlue =  UIColor(red: 0.54, green: 0.75, blue: 0.86, alpha: 1)
    static let glympsRed = UIColor(red: 0.894, green: 0.502, blue: 0.522, alpha: 1)
    static let glympsDarkGray = UIColor(red: 54/255, green: 73/255, blue: 84/255, alpha: 1.0)
}

class DeckCardView: UIView, NibLoadable {

    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var gradientView: GlympsGradientView!
    @IBOutlet weak var rightChevron: UIImageView!
    @IBOutlet weak var leftChevron: UIImageView!

    @IBOutlet weak var pageIndicator: PageIndicator!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!

    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var infoContainer: CardInfoContainerView!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var professionContainer: UIStackView!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var schoolContainer: UIStackView!

    var images: [String]?

    var userId: String?

    var stackView: UIStackView?

    var cycleLeftButton: UIButton?

    var cycleRightButton: UIButton?

    weak var moreInfoDelegate: MoreInfoDelegate?

    var imageIndex = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        imageContainer.addGestureRecognizer(tapGesture)

        imageView.layer.cornerRadius = 30.0
        imageView.clipsToBounds = true

        gradientView.layer.cornerRadius = 30.0
        gradientView.clipsToBounds = true

        imageContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        imageContainer.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.22).cgColor
        imageContainer.layer.shadowOpacity = 1
        imageContainer.layer.shadowRadius = 5
        imageContainer.layer.cornerRadius = 30.0
        imageContainer.clipsToBounds = true
        imageContainer.layer.masksToBounds = false

        textFieldContainer.layer.cornerRadius = 20.0
        textFieldContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        textFieldContainer.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10).cgColor
        textFieldContainer.layer.shadowOpacity = 1
        textFieldContainer.layer.shadowRadius = 5

        textField.attributedPlaceholder = NSAttributedString(string: "Type your message",
                                                              attributes: [.foregroundColor: UIColor.gray])

        infoContainer.layer.cornerRadius = 15.0
        infoContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        infoContainer.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.22).cgColor
        infoContainer.layer.shadowOpacity = 1
        infoContainer.layer.shadowRadius = 10

        let infoIcon = UIImage(named: "icon-info")!.withRenderingMode(.alwaysTemplate)
        moreInfoButton.setBackgroundImage(infoIcon, for: .normal)
    }

    let infoButtonColors: [UIColor] = [.glympsBlue, .glympsGreen, .glympsPurple]

    func configure(with user: User, atIndex index: Int) {
        let name = (user.name ?? "").split(separator: " ")[0]
        nameLabel.text = "Hello, \(name)"

        pageIndicator.numberOfPages = user.profileImages?.count ?? 1
        pageIndicator.currentPageIndex = 0

        let chevronsAreHidden = pageIndicator.numberOfPages < 2
        leftChevron.isHidden = chevronsAreHidden
        rightChevron.isHidden = chevronsAreHidden

        let tintColor = infoButtonColors[index % 3]
        moreInfoButton.tintColor = tintColor

        infoContainer.configure(with: user, tintColor: tintColor)
    }

    // cycle through profile images, determines whether to cycle forward or backward bassd on touch location, and then setup image accordingly
    @objc func handleTap(gesture: UITapGestureRecognizer) {

        let tapLocation = gesture.location(in: imageContainer)
        let quadrantOfTap = Int(floor(tapLocation.x * 4 / imageContainer.bounds.width))

        switch quadrantOfTap {
        case 0:
            let newIndex = imageIndex - 1
            imageIndex = newIndex > 0 ? newIndex : images!.count - 1
        case 1, 2:
            //moreInfoDelegate?.goToMoreInfo(userId: id, cardView: self)
            return
        case 3:
            fallthrough
        default:
            imageIndex = (imageIndex + 1) % images!.count
        }

        let imageUrls = images![imageIndex]

        let photoUrl = URL(string: imageUrls)
        imageView.sd_setImage(with: photoUrl)

        pageIndicator.currentPageIndex = imageIndex
    }
}
