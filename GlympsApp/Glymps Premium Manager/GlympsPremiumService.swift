//
//  GlympsPremiumService.swift
//  GlympsApp
//
//  Created by James B Morris on 7/16/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import StoreKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// an API for communicating with RevenueCat, a service Glymps uses to handle subscriptions and in-app payments to Glymps
class GlympsPremiumService: NSObject {
    
    private override init() { }
    
    static let instance = GlympsPremiumService() // PremiumService singleton
    
    var coinsToSend: Int? // coins current user spends
    
    var products = [SKProduct]() // subscription options
    
    var productToBuy: String? // selected subscription option
    
    let paymentQueue = SKPaymentQueue.default() // payment queue
    
    // retrieve all subscription options
    func getProducts() {
        
        let products: Set = [IAPProduct.coinPurchase5.rawValue,
                             IAPProduct.coinPurchase30.rawValue,
                             IAPProduct.coinPurchase75.rawValue,
                             IAPProduct.coinSubscription1Month.rawValue,
                             IAPProduct.coinSubscription6Month.rawValue,
                             IAPProduct.coinSubscription12Month.rawValue,
                             IAPProduct.usdSubscription1Month.rawValue,
                             IAPProduct.usdSubscription6Month.rawValue,
                             IAPProduct.usdSubscription12Month.rawValue]
        
        // request payment UI for products from Apple
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
        
    }
    
    // purchase product with Apple payment
    func purchase(product: IAPProduct) {
        
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        
        let payment = SKPayment(product: productToPurchase)
        
        paymentQueue.add(payment)
        
    }
    
    // restore all purchased products (i.e. after user accidentally deletes app)
    func restorePurchases() {
        
        print("Restoring purchases...")
        
        paymentQueue.restoreCompletedTransactions()
        
    }
    
    // increase current User's coins if they buy more coins
    func increaseCoins(coinAmount: Int) {
        
        var newCoins = coinAmount
        
        API.User.observeCurrentUser { (user) in
            
            newCoins += user.coins!
            self.coinsToSend = newCoins
            
            AuthService.updateCoins(coinAmount: newCoins)
        }
    }
    
    // decrease coins if they choose to purchase a subscription option that requires coins as payment method
    func decreaseCoins(coinAmount: Int) {
        
        var newCoins = 0
        
        API.User.observeCurrentUser { (user) in
            
            if (user.coins! - coinAmount) >= 0 {
                
                newCoins = (user.coins! - coinAmount)
                self.coinsToSend = newCoins
                
                AuthService.updateCoins(coinAmount: newCoins)
            } else {
                return
            }
        }
    }
    
}

// delegate functions for requester to Apple payments
extension GlympsPremiumService: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        self.products = response.products
        for product in response.products {
            print(product.localizedTitle)
        }
        
    }
}

// observer for Apple payment server: see if transaction is pending, failed, purchased, or restored
extension GlympsPremiumService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            print("\(transaction.payment.productIdentifier) : \(transaction.transactionState.status())")
            
            switch transaction.transactionState {
            case .purchasing: break
            default: queue.finishTransaction(transaction)
            }
        }
        
    }
}

// subscriber tool to subscribe current user for certain duration, depending on product purchased
extension SKPaymentTransactionState {
    
    func status() -> String {
        switch self {
        case .purchasing:
            return "Purchasing \(GlympsPremiumService.instance.productToBuy!)..."
        case .purchased:
            
            API.User.observeCurrentUser { (user) in
                if GlympsPremiumService.instance.productToBuy == "5 Coins" {
                    
                    GlympsPremiumService.instance.increaseCoins(coinAmount: 5)
                    
                } else if GlympsPremiumService.instance.productToBuy == "30 Coins" {
                    
                    GlympsPremiumService.instance.increaseCoins(coinAmount: 30)
                    
                } else if GlympsPremiumService.instance.productToBuy == "75 Coins" {
                    
                    GlympsPremiumService.instance.increaseCoins(coinAmount: 75)
                    
                } else if GlympsPremiumService.instance.productToBuy == "1 Month COIN" {
                    
                    GlympsPremiumService.instance.decreaseCoins(coinAmount: 13)
                    
                    AuthService.subscribe()
                    
                } else if GlympsPremiumService.instance.productToBuy == "6 Month COIN" {
                    
                    GlympsPremiumService.instance.decreaseCoins(coinAmount: 37)
                    
                    AuthService.subscribe()
                    
                } else if GlympsPremiumService.instance.productToBuy == "12 Month COIN" {
                    
                    GlympsPremiumService.instance.decreaseCoins(coinAmount: 83)
                    
                    AuthService.subscribe()
                    
                } else if GlympsPremiumService.instance.productToBuy == "1 Month USD" {
                    
                    AuthService.subscribe()
                    
                } else if GlympsPremiumService.instance.productToBuy == "6 Month USD" {
                    
                    AuthService.subscribe()
                    
                } else if GlympsPremiumService.instance.productToBuy == "12 Month USD" {
                    
                    AuthService.subscribe()
                    
                }
            }
            return "Purchased \(GlympsPremiumService.instance.productToBuy!)."
        case .failed:
            return "Failed \(GlympsPremiumService.instance.productToBuy!)."
        case .restored:
            return "Restored \(GlympsPremiumService.instance.productToBuy!)."
        case .deferred:
            return "Deferred \(GlympsPremiumService.instance.productToBuy!)."
        @unknown default:
            return "ERROR"
        }
    }
    
}
