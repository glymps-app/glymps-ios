//
//  OnboardingVC.swift
//  GlympsApp
//
//  Created by James B Morris on 9/5/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// walkthrough for new Glymps users :)
class OnboardingVC: UIPageViewController, UIPageViewControllerDataSource {
    
    var pageTitles = ["Welcome to Glymps!", "How it Works", "Messaging", "Heat Map", "Enable Notifications", "Enable Location", "Good Luck!"] // titles for each page
    
    var pageContent = ["Hi there!\nGlymps allows you to date naturally and make genuine in-person connections by matching with others in your immediate vicinity, especially when you're having a night out!", "You can discover those around you by swiping through the deck. The first people in your feed are closest to you, and the further you swipe, the further they get! Tap the info button to learn more about them. If you like someone, tap the message button to send them a message!", """
You can think of the first message you send as a "request to match". If they message you back, you got yourself a match, and you can continue to message them!
""", "If you feel like the number of people in your feed are limited, you can check out the heat map, which shows areas closeby that have a high concentration of users!", "Glymps sends you push notifications to notify you of new message requests, matches, messages, and events nearby. To stay in the loop, please enable notifications.", """
In order to get potential matches in your deck, to get messaged by others, and to be able to use the heat map, Glymps requires location services. To enjoy all of this, please tap the button below and select "Always Allow."
""", "Ready when you are! Let's get you signed up!"] // labels for each page
    
    var pageImage = [#imageLiteral(resourceName: "glymps_logo_with_title"), #imageLiteral(resourceName: "swipe"), #imageLiteral(resourceName: "message-icon1"), #imageLiteral(resourceName: "heat-map"), #imageLiteral(resourceName: "notification"), #imageLiteral(resourceName: "location"), #imageLiteral(resourceName: "rocket")] // background images for each page
    
    // setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        // set scroll starting point
        if let startingVC = viewControllerAtIndex(index: 0) {
            setViewControllers([startingVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! OnboardingContentVC).index
        index += 1
        return viewControllerAtIndex(index: index)
    } // go to next page
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! OnboardingContentVC).index
        index -= 1
        return viewControllerAtIndex(index: index)
    } // go to previous page
    
    // handle overScroll out of index and set next page to be displayed
    func viewControllerAtIndex(index: Int) -> OnboardingContentVC? {
        if index < 0 || index >= pageContent.count {
            print(index)
            return nil
        }
        if let pageContentVC = storyboard?.instantiateViewController(withIdentifier: "OnboardingContentVC") as? OnboardingContentVC {
            
            pageContentVC.contentTitle = pageTitles[index]
            pageContentVC.content = pageContent[index]
            pageContentVC.index = index
            pageContentVC.imageForPage = pageImage[index]
            
            return pageContentVC
        }
        return nil
    }
    
    func forward(index: Int) {
        if let nextVC = viewControllerAtIndex(index: index + 1) {
            setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
        }
    } // function that scrolls to next page

}
