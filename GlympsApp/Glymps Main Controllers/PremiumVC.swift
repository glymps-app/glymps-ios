//
//  PremiumVC.swift
//  GlympsApp
//
//  Created by James B Morris on 7/14/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import Purchases

// upsell screen for current user to subscribe and become a Glymps Premium user :)
class PremiumVC: UIViewController {
    
    @IBOutlet weak var oneMonthUSDBtn: UIButton!
    
    @IBOutlet weak var oneMonthUSDLabel: UILabel!
    
    @IBOutlet weak var sixMonthUSDBtn: UIButton!
    
    @IBOutlet weak var sixMonthUSDLabel: UILabel!
    
    @IBOutlet weak var twelveMonthUSDBtn: UIButton!
    
    @IBOutlet weak var twelveMonthUSDLabel: UILabel!
    
    @IBOutlet weak var oneMonthCoinBtn: UIButton!
    
    @IBOutlet weak var oneMonthCoinLabel: UILabel!
    
    @IBOutlet weak var sixMonthCoinBtn: UIButton!
    
    @IBOutlet weak var sixMonthCoinLabel: UILabel!
    
    @IBOutlet weak var twelveMonthCoinBtn: UIButton!

    @IBOutlet weak var twelveMonthCoinLabel: UILabel!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    @IBOutlet weak var dropView: UIView!
    
    var coinsToSend: Int?
    
    // subscription products (USD)
    var glympsMonthly: Purchases.Package?
    var glympsSemiAnnually: Purchases.Package?
    var glympsYearly: Purchases.Package?
    
    // subscription products (Glymps Coins)
    var glympsMonthlyCoin: Purchases.Package?
    var glympsSemiAnnuallyCoin: Purchases.Package?
    var glympsYearlyCoin: Purchases.Package?
    
    var chosenPayment = ["6 Month USD"] {
        willSet {
            if self.chosenPayment.isEmpty == true {
                continueBtn.isEnabled = false
            } else {
                continueBtn.isEnabled = true
            }
        }
        didSet {
            if self.chosenPayment.isEmpty == true {
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
        
        setupPurchases()

        continueBtn.isEnabled = true
        continueBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        
        sixMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        sixMonthUSDBtn.layer.borderWidth = 1
        sixMonthUSDLabel.textColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
    }
    
    // setup products from RevenueCat
    func setupPurchases() {
        
        Purchases.shared.offerings { (offerings, error) in
            if let packages = offerings?.current?.availablePackages {
                // Display packages for sale
                
                for package in packages {
                    if package.product.productIdentifier == "com.glymps.Glymps.1MonthCoinSubscription" {
                        self.glympsMonthlyCoin = package
                    }
                    if package.product.productIdentifier == "com.glymps.Glymps.6MonthCoinSubscription" {
                        self.glympsSemiAnnuallyCoin = package
                    }
                    if package.product.productIdentifier == "com.glymps.Glymps.12MonthCoinSubscription" {
                        self.glympsYearlyCoin = package
                    }
                    if package.product.productIdentifier == "com.glymps.Glymps.1MonthUSDSubscription" {
                        self.glympsMonthly = package
                    }
                    if package.product.productIdentifier == "com.glymps.Glymps.6MonthUSDSubscription" {
                        self.glympsSemiAnnually = package
                    }
                    if package.product.productIdentifier == "com.glymps.Glymps.12MonthUSDSubscription" {
                        self.glympsYearly = package
                    }
                }
                
                print("All entitlements fetched successfully 🎉")
                
            } else {
                //print("Error: \(error!.localizedDescription)")
            }
        }

    }
    
    // purchase subscription product
    func makePurchase(package: Purchases.Package) {
        
        Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
            if purchaserInfo?.entitlements.active.first != nil {
                // Unlock that great "pro" content
                
                if package == self.glympsMonthlyCoin {

                    GlympsPremiumService.instance.decreaseCoins(coinAmount: 13)
                    AuthService.subscribe()

                } else if package == self.glympsSemiAnnuallyCoin {

                    GlympsPremiumService.instance.decreaseCoins(coinAmount: 37)
                    AuthService.subscribe()

                } else if package == self.glympsYearlyCoin {

                    GlympsPremiumService.instance.decreaseCoins(coinAmount: 83)
                    AuthService.subscribe()

                } else {
                    AuthService.subscribe()
                }

                print("Purchased Glymps Premium 🎉")
                
            } else {
                print("Error: \(error!.localizedDescription)")
            }
        }
    }
    
    // buy a Glymps monthly subscription
    func buyGlympsMonthly() {
        guard let package = glympsMonthly else { return }
        makePurchase(package: package)
    }
    // buy a Glymps bi-annual subscription
    func buyGlympsSemiAnnual() {
        guard let package = glympsSemiAnnually else { return }
        makePurchase(package: package)
    }
    // buy a Glymps yearly subscription
    func buyGlympsYearly() {
        guard let package = glympsYearly else { return }
        makePurchase(package: package)
    }

    // buy a Glymps monthly subscription w/ coins
    func buyGlympsMonthlyCoin() {
        guard let package = glympsMonthlyCoin else { return }
        makePurchase(package: package)
    }
    // buy a Glymps bi-annual subscription w/ coins
    func buyGlympsSemiAnnualCoin() {
        guard let package = glympsSemiAnnuallyCoin else { return }
        makePurchase(package: package)
    }
    // buy a Glymps yearly subscription w/ coins
    func buyGlympsYearlyCoin() {
        guard let package = glympsYearlyCoin else { return }
        makePurchase(package: package)
    }
    
    // select one month subscription
    @IBAction func oneMonthUSDBtnWasPressed(_ sender: Any) {
        oneMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        oneMonthUSDBtn.layer.borderWidth = 1
        oneMonthUSDLabel.textColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        sixMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        sixMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        twelveMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        twelveMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        oneMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        oneMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        sixMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        sixMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        twelveMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        twelveMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        if chosenPayment.isEmpty == true {
            chosenPayment.append("1 Month USD")
        } else {
            chosenPayment.removeAll()
            chosenPayment.append("1 Month USD")
        }
        
        if continueBtn.isEnabled == true {
            continueBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        } else {
            continueBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        }
    }
    
    // select six month subscription
    @IBAction func sixMonthUSDBtnWasPressed(_ sender: Any) {
        oneMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        oneMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        sixMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        sixMonthUSDBtn.layer.borderWidth = 1
        sixMonthUSDLabel.textColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        twelveMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        twelveMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        oneMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        oneMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        sixMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        sixMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        twelveMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        twelveMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        if chosenPayment.isEmpty == true {
            chosenPayment.append("6 Month USD")
        } else {
            chosenPayment.removeAll()
            chosenPayment.append("6 Month USD")
        }
        
        if continueBtn.isEnabled == true {
            continueBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        } else {
            continueBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        }
    }
    
    // select one year subscription
    @IBAction func twelveMonthUSDBtnWasPressed(_ sender: Any) {
        oneMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        oneMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        sixMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        sixMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        twelveMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        twelveMonthUSDBtn.layer.borderWidth = 1
        twelveMonthUSDLabel.textColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        oneMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        oneMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        sixMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        sixMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        twelveMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        twelveMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        if chosenPayment.isEmpty == true {
            chosenPayment.append("12 Month USD")
        } else {
            chosenPayment.removeAll()
            chosenPayment.append("12 Month USD")
        }
        
        if continueBtn.isEnabled == true {
            continueBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        } else {
            continueBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        }
    }
    
    // select one month subscription w/ coins
    @IBAction func oneMonthCoinBtnWasPressed(_ sender: Any) {
        oneMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        oneMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        sixMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        sixMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        twelveMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        twelveMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        oneMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        oneMonthCoinBtn.layer.borderWidth = 1
        oneMonthCoinLabel.textColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        sixMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        sixMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        twelveMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        twelveMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        if chosenPayment.isEmpty == true {
            chosenPayment.append("1 Month COIN")
        } else {
            chosenPayment.removeAll()
            chosenPayment.append("1 Month COIN")
        }
        
        if continueBtn.isEnabled == true {
            continueBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        } else {
            continueBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        }
    }
    
    // select six month subscription w/ coins
    @IBAction func sixMonthCoinBtnWasPressed(_ sender: Any) {
        oneMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        oneMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        sixMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        sixMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        twelveMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        twelveMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        oneMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        oneMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        sixMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        sixMonthCoinBtn.layer.borderWidth = 1
        sixMonthCoinLabel.textColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        twelveMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        twelveMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        if chosenPayment.isEmpty == true {
            chosenPayment.append("6 Month COIN")
        } else {
            chosenPayment.removeAll()
            chosenPayment.append("6 Month COIN")
        }
        
        if continueBtn.isEnabled == true {
            continueBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        } else {
            continueBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        }
    }
    
    // select one year subscription w/ coins
    @IBAction func twelveMonthCoinBtnWasPressed(_ sender: Any) {
        oneMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        oneMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        sixMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        sixMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        twelveMonthUSDBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        twelveMonthUSDLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        oneMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        oneMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        sixMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3521778682)
        sixMonthCoinLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        twelveMonthCoinBtn.layer.borderColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        twelveMonthCoinBtn.layer.borderWidth = 1
        twelveMonthCoinLabel.textColor = #colorLiteral(red: 0.9233818054, green: 0.6821665168, blue: 0.2156540751, alpha: 1)
        
        if chosenPayment.isEmpty == true {
            chosenPayment.append("12 Month COIN")
        } else {
            chosenPayment.removeAll()
            chosenPayment.append("12 Month COIN")
        }
        
        if continueBtn.isEnabled == true {
            continueBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        } else {
            continueBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            continueBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        }
    }
    
    // continue to payment
    @IBAction func continueBtnWasPressed(_ sender: Any) {
        // initiate in-app purchase via Apple, with selected data
        // charge user credentials
        // change user "isPremium" attribute to true
        // dismiss payment view and payment option view
        
        if chosenPayment[0] == "1 Month USD" {
            buyGlympsMonthly()
        } else if chosenPayment[0] == "6 Month USD" {
            buyGlympsSemiAnnual()
        } else if chosenPayment[0] == "12 Month USD" {
            buyGlympsYearly()
        } else if chosenPayment[0] == "1 Month COIN" {
            buyGlympsMonthlyCoin()
        } else if chosenPayment[0] == "6 Month COIN" {
            buyGlympsSemiAnnualCoin()
        } else if chosenPayment[0] == "12 Month COIN" {
            buyGlympsYearlyCoin()
        } else {
            return
        }
    }
    
    // dismiss popover
    @IBAction func dismissBtnWasPressed(_ sender: Any) {
        if let coinsToSend = GlympsPremiumService.instance.coinsToSend {
            self.coinsToSend = coinsToSend
        }
        // update coin amount on UI of main profile screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            if let coins = self.coinsToSend {
                let presenter = self.presentingViewController?.presentingViewController as! ProfileVC
                presenter.coinsViewLabel.text = "\(coins)"
                self.dismiss(animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    

}
