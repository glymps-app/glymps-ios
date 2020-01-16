//
//  AdvertiserView.swift
//  GlympsApp
//
//  Created by James B Morris on 7/16/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import SDWebImage
//import SmaatoSDKBanner

// A card in the "card deck" that displays an ad
class AdvertiserView: UIView {
    
    //var bannerView: SMABannerView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 15
        layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        layer.borderWidth = 1
        clipsToBounds = true
        
        backgroundColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)

        //bannerView?.fillSuperview()
    }
    
    // default view encoder
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

} 
