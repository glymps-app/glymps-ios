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
    
    case coinPurchase5 = "JamesBMorris.GlympsApp.CoinPurchase5"
    case coinPurchase30 = "JamesBMorris.GlympsApp.CoinPurchase30"
    case coinPurchase75 = "JamesBMorris.GlympsApp.CoinPurchase75"
    
    case coinSubscription1Month = "JamesBMorris.GlympsApp.CoinSubscription1Month"
    case coinSubscription6Month = "JamesBMorris.GlympsApp.CoinSubscription6Month"
    case coinSubscription12Month = "JamesBMorris.GlympsApp.CoinSubscription12Month"
    
    case usdSubscription1Month = "JamesBMorris.GlympsApp.USDSubscription1Month"
    case usdSubscription6Month = "JamesBMorris.GlympsApp.USDSubscription6Month"
    case usdSubscription12Month = "JamesBMorris.GlympsApp.USDSubscription12Month"
}
