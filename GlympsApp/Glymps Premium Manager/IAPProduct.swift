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
        
    case coinSubscription1Month = "com.glymps.Glymps.1MonthCoin"
    case coinSubscription6Month = "com.glymps.Glymps.6MonthCoin"
    case coinSubscription12Month = "com.glymps.Glymps.12MonthCoin"
    
    case usdSubscription1Month = "com.glymps.Glymps.1MonthUSD"
    case usdSubscription6Month = "com.glymps.Glymps.6MonthUSD"
    case usdSubscription12Month = "com.glymps.Glymps.12MonthUSD"
}
