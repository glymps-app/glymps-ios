//
//  PageIndicator.swift
//  GlympsApp
//
//  Created by Charley Luckhardt on 6/18/20.
//  Copyright © 2020 James B Morris. All rights reserved.
//

import UIKit

@IBDesignable
class PageIndicator: UIView {

    @IBInspectable var numberOfPages: Int = 0 {
        didSet {
            configure(forNewPageCount: numberOfPages)
        }
    }

    var currentPageIndex = 0 {
        didSet {
            selectPage(at: currentPageIndex)
        }
    }

    private lazy var stackView: UIStackView = {
        backgroundColor = .clear

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 14.0

        addSubview(stackView)
        stackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil)
        stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true

        return stackView
    }()

    private let inactiveDotColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.78, alpha: 1.0)

    private func configure(forNewPageCount pageCount: Int) {
        let currentCount = stackView.arrangedSubviews.count

        let diff = pageCount - currentCount
        if diff < 0 {
            let subviews = stackView.arrangedSubviews
            for i in 0..<abs(diff) {
                subviews[i].removeFromSuperview()
            }
        } else if diff > 0 {
            for _ in 0..<abs(diff) {
                stackView.addArrangedSubview(makeDotView())
            }
        }
    }

    private func selectPage(at index: Int) {
        for (i, view) in stackView.arrangedSubviews.enumerated() {
            view.backgroundColor = i == index ? .white : inactiveDotColor
        }
    }

    private func makeDotView() -> UIView {
        let dotView = UIView()
        
        dotView.backgroundColor = inactiveDotColor
        dotView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: 6.0, height: 6.0))
        dotView.layer.cornerRadius = 3.0
        dotView.clipsToBounds = true

        return dotView
    }
}
