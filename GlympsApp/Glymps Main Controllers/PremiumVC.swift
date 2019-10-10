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
    
    var coinsToSend: Int?
    
    // subscription products (USD)
    var glympsMonthly: SKProduct?
    var glympsSemiAnnually: SKProduct?
    var glympsYearly: SKProduct?
    
    // subscription products (Glymps Coins)
    var glympsMonthlyCoin: SKProduct?
    var glympsSemiAnnuallyCoin: SKProduct?
    var glympsYearlyCoin: SKProduct?
    
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
        
        Purchases.shared.entitlements { (entitlements, error) in
            if let e = error {
                print(e.localizedDescription)
            }
            
            guard let pro = entitlements?["pro"] else {
                print("Error finding pro entitlement")
                return
            }
            
            guard let glympsMonthly = pro.offerings["monthly"] else {
                print("Error finding monthly offering")
                return
            }
            guard let glympsSemiAnnually = pro.offerings["semi-annually"] else {
                print("Erro finding semi-annual offering")
                return
            }
            guard let glympsYearly = pro.offerings["yearly"] else {
                print("Error finding yearly offering")
                return
            }
            
            guard let glympsMonthlyCoin = pro.offerings["monthly (coin)"] else {
                print("Error finding monthly coin offering")
                return
            }
            guard let glympsSemiAnnuallyCoin = pro.offerings["semi-annually (coin)"] else {
                print("Erro finding semi-annual coin offering")
                return
            }
            guard let glympsYearlyCoin = pro.offerings["yearly (coin)"] else {
                print("Error finding yearly coin offering")
                return
            }
            
            guard let monthlyProduct = glympsMonthly.activeProduct else {
                print("Error finding monthly active product")
                return
            }
            guard let semiAnnualProduct = glympsSemiAnnually.activeProduct else {
                print("Error finding semi-annual active product")
                return
            }
            guard let yearlyProduct = glympsYearly.activeProduct else {
                print("Error finding yearly active product")
                return
            }
            
            guard let monthlyCoinProduct = glympsMonthlyCoin.activeProduct else {
                print("Error finding monthly active coin product")
                return
            }
            guard let semiAnnualCoinProduct = glympsSemiAnnuallyCoin.activeProduct else {
                print("Error finding semi-annual active coin product")
                return
            }
            guard let yearlyCoinProduct = glympsYearlyCoin.activeProduct else {
                print("Error finding yearly active coin product")
                return
            }
            
            self.glympsMonthly = monthlyProduct
            self.glympsSemiAnnually = semiAnnualProduct
            self.glympsYearly = yearlyProduct
            
            self.glympsMonthlyCoin = monthlyCoinProduct
            self.glympsSemiAnnuallyCoin = semiAnnualCoinProduct
            self.glympsYearlyCoin = yearlyCoinProduct
            
            print("All entitlements fetched successfully 🎉")
            
        }
        
    }
    
    // purchase subscription product
    func makePurchase(product: SKProduct) {
        
        Purchases.shared.makePurchase(product) { (transaction, purchaserInfo, error, userCancelled) in
            if let e = error {
                print("PURCHASE ERROR: - \(e.localizedDescription)")
                
            } else if purchaserInfo?.activeEntitlements.contains("pro") ?? false {
                
                if product == self.glympsMonthlyCoin {
                    
                    GlympsPremiumService.instance.decreaseCoins(coinAmount: 13)
                    AuthService.subscribe()
                    
                } else if product == self.glympsSemiAnnuallyCoin {
                    
                    GlympsPremiumService.instance.decreaseCoins(coinAmount: 37)
                    AuthService.subscribe()
                    
                } else if product == self.glympsYearlyCoin {
                    
                    GlympsPremiumService.instance.decreaseCoins(coinAmount: 83)
                    AuthService.subscribe()
                    
                } else {
                    AuthService.subscribe()
                }
                
                print("Purchased Glymps Premium 🎉")
            }
        }
    }
    
    // buy a Glymps monthly subscription
    func buyGlympsMonthly() {
        guard let product = glympsMonthly else { return }
        makePurchase(product: product)
    }
    // buy a Glymps bi-annual subscription
    func buyGlympsSemiAnnual() {
        guard let product = glympsSemiAnnually else { return }
        makePurchase(product: product)
    }
    // buy a Glymps yearly subscription
    func buyGlympsYearly() {
        guard let product = glympsYearly else { return }
        makePurchase(product: product)
    }
    
    // buy a Glymps monthly subscription w/ coins
    func buyGlympsMonthlyCoin() {
        guard let product = glympsMonthlyCoin else { return }
        makePurchase(product: product)
    }
    // buy a Glymps bi-annual subscription w/ coins
    func buyGlympsSemiAnnualCoin() {
        guard let product = glympsSemiAnnuallyCoin else { return }
        makePurchase(product: product)
    }
    // buy a Glymps yearly subscription w/ coins
    func buyGlympsYearlyCoin() {
        guard let product = glympsYearlyCoin else { return }
        makePurchase(product: product)
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
