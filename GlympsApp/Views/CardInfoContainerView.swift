//
//  CardInfoContainerView.swift
//  GlympsApp
//
//  Created by Charley Luckhardt on 6/19/20.
//  Copyright © 2020 James B Morris. All rights reserved.
//

import UIKit

enum UserInfoEntry {
    case profession
    case school
    case bio
}

extension Optional where Wrapped == String {
    func asNilIfEmpty() -> String? {
        return self?.isEmpty ?? true ? nil : self!
    }
}

extension User {
    func description(for entry: UserInfoEntry) -> String? {
        switch entry {
        case .profession:
            if let profession = profession.asNilIfEmpty(), let company = company.asNilIfEmpty() {
                return "\(profession) @ \(company)"
            }
        case .school:
            return "University of Arizona" //break
        case .bio:
            return bio.asNilIfEmpty()
        }
        return nil
    }
}

class CardInfoContainerView: UIView {

    enum Item: CaseIterable, Hashable {
        static var allCases: [CardInfoContainerView.Item] = [.info(.profession), .info(.school), .info(.bio), .noInfo, .hideUser]

        case info(UserInfoEntry)
        case noInfo, hideUser

        var iconImageName: String {
            switch self {
            case .info(let entry):
                switch entry {
                case .profession:
                    return "icon-briefcase"
                case .school:
                    return "icon-college"
                case .bio:
                    return "icon-college"
                }
            case .noInfo:
                return "icon-cancel"
            case .hideUser:
                return "icon-cancel"
            }
        }
    }

    var itemViewMap: [Item: CardInfoItemView] = [:]

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 7
        stackView.axis = .vertical
        stackView.alignment = .leading

        addSubview(stackView)
        stackView.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 16, left: 24, bottom: 16, right: 24))
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        return stackView
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        for item in Item.allCases {
            let image = UIImage(named: item.iconImageName)!.withRenderingMode(.alwaysTemplate)
            let itemView = CardInfoItemView()
            itemView.imageView.image = image
            stackView.addArrangedSubview(itemView)

            switch item {
            case .noInfo: itemView.label.text = "No bio, career, or school added"
            case .hideUser: itemView.label.text = "Hide User for 24 Hours"
            default: break
            }

            itemViewMap[item] = itemView
        }
    }

    func configure(with user: User, tintColor: UIColor) {
        var noInfo = true

        for item in Item.allCases {
            guard let itemView =  itemViewMap[item] else { return }

            switch item {
            case .info(let entry):
                if let entryDescription = user.description(for: entry) {
                    noInfo = false
                    itemView.isHidden = false
                    itemView.label.text = entryDescription
                } else {
                    itemView.isHidden = true
                }
            case .noInfo:
                itemView.isHidden = !noInfo
            case .hideUser:
                itemView.isHidden = true
            }
        }
    }
}

class CardInfoItemView: UIStackView {

    let imageView = UIImageView()
    let label = UILabel()

    init() {
        super.init(frame: .zero)

        axis = .horizontal
        spacing = 12

        imageView.tintColor = .gray

        label.font = UIFont(descriptor: .init(name: "Helvetica", size: 13.0), size: 13.0)
        label.textColor = .gray

        addArrangedSubview(imageView)
        addArrangedSubview(label)

        imageView.heightAnchor.constraint(equalToConstant: 14.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 14.0).isActive = true

    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
