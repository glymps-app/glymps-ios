//
//  IAPProduct.swift
//  GlympsApp
//
//  Created by James B Morris on 7/18/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation

// list of Glymps Premium's subscription products
enum IAPProduct: String {
    
    case coinPurchase5 = "com.glymps.Glymps.5Coins"
    case coinPurchase30 = "com.glymps.Glymps.30Coins"
    case coinPurchase75 = "com.glymps.Glymps.75Coins"
    
    case coinSubscription1Month = "com.glymps.Glymps.1MonthCoinSubscription"
    case coinSubscription6Month = "com.glymps.Glymps.6MonthCoinSubscription"
    case coinSubscription12Month = "com.glymps.Glymps.12MonthCoinSubscription"
    
    case usdSubscription1Month = "com.glymps.Glymps.1MonthUSDSubscription"
    case usdSubscription6Month = "com.glymps.Glymps.6MonthUSDSubscription"
    case usdSubscription12Month = "com.glymps.Glymps.12MonthUSDSubscription"
}
