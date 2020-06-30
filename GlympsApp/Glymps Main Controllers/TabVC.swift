//
//  TabVC.swift
//  GlympsApp
//
//  Created by James B Morris on 2/22/20.
//  Copyright © 2020 James B Morris. All rights reserved.
//

import UIKit

class TabVC: UITabBarController {

    let stackView = UIStackView()

    let indicator = UIView()
    var indicatorConstraints: [NSLayoutConstraint] = []

    struct Item: Equatable {
        let imageName: String
        let index: Int

        static let account = Item(imageName: "account-icon", index: 0)
        static let glymps = Item(imageName: "icon-tab-glymps", index: 1)
        static let messages = Item(imageName: "icon-message", index: 2)

        static let all: [Item] = [.account, .glymps, .messages]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UITabBar.appearance()
        appearance.tintColor = .clear
        appearance.backgroundColor = .clear
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()

        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center

        for item in Item.all {
            let button = UIButton(type: .system)
            button.setBackgroundImage(UIImage(named: item.imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.isUserInteractionEnabled = false
            stackView.addArrangedSubview(button)

            let width: CGFloat
            let height: CGFloat

            switch item {
            case .account:
                width = 29
                height = 25
            case .glymps:
                width = 34
                height = 34
            case .messages:
                width = 27
                height = 21
            default:
                fatalError()
            }

            button.widthAnchor.constraint(equalToConstant: width).isActive = true
            button.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        let toolbar = UIView()
        toolbar.backgroundColor = .white
        toolbar.isUserInteractionEnabled = false

        tabBar.addSubview(toolbar)
        toolbar.anchor(top: tabBar.topAnchor, leading: tabBar.leadingAnchor, bottom: nil, trailing: tabBar.trailingAnchor, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0))
        toolbar.heightAnchor.constraint(equalToConstant: 100.0).isActive = true

        toolbar.layer.cornerRadius = 30.0
        toolbar.layer.shadowOffset = CGSize(width: 0, height: 1)
        toolbar.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor //UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        toolbar.layer.shadowOpacity = 1
        toolbar.layer.shadowRadius = 10
        toolbar.clipsToBounds = true
        toolbar.layer.masksToBounds = false

//        let imageView = UIImageView(image: UIImage(named: "glymps-hbg"))
//        toolbar.addSubview(imageView)
//        imageView.fillSuperview()

        toolbar.addSubview(stackView)
        stackView.isUserInteractionEnabled = false
        stackView.anchor(top: toolbar.topAnchor, leading: toolbar.leadingAnchor, bottom: nil, trailing: toolbar.trailingAnchor, padding: .init(top: 12.0, left: 64.0, bottom: 0.0, right: 64.0))

        indicator.backgroundColor = .glympsBlue
        toolbar.addSubview(indicator)
        indicator.anchor(top: tabBar.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 58.0, left: 0, bottom: 0, right: 0), size: .init(width: 38.0, height: 4.0))
        indicatorConstraints = stackView.arrangedSubviews.map { indicator.centerXAnchor.constraint(equalTo: $0.centerXAnchor) }

        selectedIndex = 1
    }

    override var selectedViewController: UIViewController? {
        didSet {
            if let oldValue = oldValue {
                tabBarIndexDidUpdate(selectedIndex, fromPrevious: viewControllers?.firstIndex(of: oldValue) ?? nil)
            } else {
                tabBarIndexDidUpdate(selectedIndex, fromPrevious: nil)
            }
        }
    }

    override var selectedIndex: Int {
        didSet {
            tabBarIndexDidUpdate(selectedIndex, fromPrevious: oldValue)
        }
    }

    func tabBarIndexDidUpdate(_ index: Int, fromPrevious previousIndex: Int?) {
        guard index != previousIndex else { return }

        for (viewIndex, view) in stackView.arrangedSubviews.enumerated() {
            let button = view as! UIButton
            if index == viewIndex {
                button.tintColor = .glympsBlue
            } else {
                button.tintColor = .glympsDarkGray
            }

            indicatorConstraints[viewIndex].isActive = false
        }

        indicator.layer.removeAllAnimations()

        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.indicatorConstraints[index].isActive = true
            self.view.layoutIfNeeded()
        }
    }
}
