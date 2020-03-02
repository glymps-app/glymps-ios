//
//  BuyCoinsVC.swift
//  GlympsApp
//
//  Created by James B Morris on 7/17/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// screen for current user to buy more coins (to pay for Premium feature if they don't wish to subscribe)
class BuyCoinsVC: UIViewController {
 
    @IBOutlet weak var fiveCoinsLabel: UILabel!
    
    @IBOutlet weak var fiveCoinsBtn: UIButton!
    
    @IBOutlet weak var thirtyCoinsLabel: UILabel!
    
    @IBOutlet weak var thirtyCoinsBtn: UIButton!
    
    @IBOutlet weak var seventyFiveCoinsLabel: UILabel!
    
    @IBOutlet weak var seventyFiveCoinsBtn: UIButton!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    @IBOutlet weak var dropView: UIView!
    
    var coinsToSend: Int?
    
    var chosenCoins = ["30 Coins"] {
        willSet {
            if self.chosenCoins.isEmpty == true {
                continueBtn.isEnabled = false
            } else {
                continueBtn.isEnabled = true
            }
        }
        didSet {
            if self.chosenCoins.isEmpty == true {
                continueBtn.isEnabled = false
            } else {
                continueBtn.isEnabled = true
            }
            
        }
    }

    // setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropView.dropShadow(color: .darkGray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 20, scale: true)
        
        GlympsPremiumService.instance.getProducts()

        continueBtn.isEnabled = true
        continueBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        
        thirtyCoinsBtn.layer.borderColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        thirtyCoinsBtn.layer.borderWidth = 1
        thirtyCoinsLabel.textColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
    }
    
    // buy 5 Glymps coins
    @IBAction func fiveCoinsBtnWasPressed(_ sender: Any) {
        fiveCoinsBtn.layer.borderColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        fiveCoinsBtn.layer.borderWidth = 1
        fiveCoinsLabel.textColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        thirtyCoinsBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        thirtyCoinsLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        seventyFiveCoinsBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        seventyFiveCoinsLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        if chosenCoins.isEmpty == true {
            chosenCoins.append("5 Coins")
        } else {
            chosenCoins.removeAll()
            chosenCoins.append("5 Coins")
        }
        
        if continueBtn.isEnabled == true {
            continueBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        } else {
            continueBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        }
    }
    
    // buy 30 Glymps coins
    @IBAction func thirtyCoinsBtnWasPressed(_ sender: Any) {
        fiveCoinsBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        fiveCoinsLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        thirtyCoinsBtn.layer.borderColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        thirtyCoinsBtn.layer.borderWidth = 1
        thirtyCoinsLabel.textColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        seventyFiveCoinsBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        seventyFiveCoinsLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        if chosenCoins.isEmpty == true {
            chosenCoins.append("30 Coins")
        } else {
            chosenCoins.removeAll()
            chosenCoins.append("30 Coins")
        }
        
        if continueBtn.isEnabled == true {
            continueBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        } else {
            continueBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        }
    }
    
    // buy 75 Glymps coins
    @IBAction func seventyFiveCoinsBtnWasPressed(_ sender: Any) {
        fiveCoinsBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        fiveCoinsLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        thirtyCoinsBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        thirtyCoinsLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        seventyFiveCoinsBtn.layer.borderColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        seventyFiveCoinsBtn.layer.borderWidth = 1
        seventyFiveCoinsLabel.textColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        
        if chosenCoins.isEmpty == true {
            chosenCoins.append("75 Coins")
        } else {
            chosenCoins.removeAll()
            chosenCoins.append("75 Coins")
        }
        
        if continueBtn.isEnabled == true {
            continueBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        } else {
            continueBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        }
    }
    
    // continue to purchase
    @IBAction func continueBtnWasPressed(_ sender: Any) {
        // initiate in-app purchase via Apple, with selected data
        // charge user credentials
        // update user coin amount
        // dismiss payment view and payment option view
        
        if chosenCoins[0] == "5 Coins" {
            GlympsPremiumService.instance.productToBuy = chosenCoins[0]
            GlympsPremiumService.instance.purchase(product: .coinPurchase5)
            GlympsPremiumService.instance.restorePurchases()
        } else if chosenCoins[0] == "30 Coins" {
            GlympsPremiumService.instance.productToBuy = chosenCoins[0]
            GlympsPremiumService.instance.purchase(product: .coinPurchase30)
            GlympsPremiumService.instance.restorePurchases()
        } else if chosenCoins[0] == "75 Coins" {
            GlympsPremiumService.instance.productToBuy = chosenCoins[0]
            GlympsPremiumService.instance.purchase(product: .coinPurchase75)
            GlympsPremiumService.instance.restorePurchases()
        } else {
            return
        }
    }
    
    // go back to main profile screen
    @IBAction func dismissBtnWasPressed(_ sender: Any) {
        
        if let coinsToSend = GlympsPremiumService.instance.coinsToSend {
            self.coinsToSend = coinsToSend
        }
        // update displayed coin amount on main profile screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    
            if let coins = self.coinsToSend {
                let presenter = self.presentingViewController as! ProfileVC
                presenter.coinsViewLabel.text = "\(coins)"
                self.dismiss(animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

}
