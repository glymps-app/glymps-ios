//
//  SwipingPhotosController.swift
//  GlympsApp
//
//  Created by James B Morris on 7/13/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import SDWebImage

// profile image display for user detail screen
class SwipingPhotosController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // setup other user CardView
    var cardView: CardView! {
        didSet {
            controllers = cardView.images!.map({ (imageUrl) -> UIViewController in
                let photoController = PhotoController(imageUrl: imageUrl)
                return photoController
            })
            
            setViewControllers([controllers.first!], direction: .forward, animated: false)
            
            setupBarViews()
        }
    }
    
    let barStackView = UIStackView(arrangedSubviews: [])
    
    let deselectedColor = UIColor(white: 0, alpha: 0.1)
    
    // setup cycling bars to display number of/ index of profile image
    func setupBarViews() {
        cardView.images?.forEach({ (_) in
            let barView = UIView()
            barView.backgroundColor = deselectedColor
            barView.layer.cornerRadius = 2
            barStackView.addArrangedSubview(barView)
        })
        barStackView.arrangedSubviews.first?.backgroundColor = .white
        barStackView.spacing = 4
        barStackView.distribution = .fillEqually
        view.addSubview(barStackView)
        let paddingTop = UIApplication.shared.statusBarFrame.height + 8
        barStackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: paddingTop, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
    }
    
    // "move" profile image index bar that is setup above
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let currentPhotoController = viewControllers?.first
        if let index = controllers.firstIndex(where: { $0 == currentPhotoController}) {
            barStackView.arrangedSubviews.forEach({ $0.backgroundColor = deselectedColor })
            barStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    var controllers = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        view.backgroundColor = .white
        
    }
    
    // setup next image
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: { $0 == viewController}) ?? 0
        if index == controllers.count - 1 { return nil }
        return controllers[index + 1]
    }
    
    // setup previous image
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: { $0 == viewController}) ?? 0
        if index == 0 { return nil}
        return controllers[index - 1]
    }
}

// image to be displayed on SwipingPhotosController
class PhotoController: UIViewController {
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
    
    init(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    // default encoder
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
