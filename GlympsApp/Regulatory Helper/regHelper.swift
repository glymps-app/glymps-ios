//
//  regHelper.swift
//  GlympsApp
//
//  Created by James B Morris on 2/10/21.
//  Copyright © 2021 James B Morris. All rights reserved.
//

import UIKit

class RegulatoryHelper {
    
    // function to determine if user is subject to GDPR within the European Economic Area
    public func isSubjectToGDPR() {
        
        var components = URLComponents()
        components.scheme = "http"
        components.host = "ip-api.com"
        components.path = "/json"
        
        let query = URLQueryItem(name: "fields", value: "continent,country,regionName")
        components.queryItems = [query]
        
        let ipURL = components.url
        
        var request = URLRequest(url: ipURL!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else { return }
            do {
                let continentJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
                print(continentJSON)
                let continent = continentJSON["continent"] as! String
                print(continent)
                if continent == "Europe" {
                    isInEurope = true
                } else {
                    isInEurope = false
                }
            } catch {
                print("An error has occurred: \(error.localizedDescription)")
            }
        }.resume()
        
    }
    
    public func isSubjectToCCPA() {
        
        var components = URLComponents()
        components.scheme = "http"
        components.host = "ip-api.com"
        components.path = "/json"
        
        let query = URLQueryItem(name: "fields", value: "continent,country,regionName")
        components.queryItems = [query]
        
        let ipURL = components.url
        
        var request = URLRequest(url: ipURL!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else { return }
            do {
                let stateJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
                print(stateJSON)
                let state = stateJSON["regionName"] as! String
                print(state)
                if state == "California" {
                    isInCalifornia = true
                } else {
                    isInCalifornia = false
                }
            } catch {
                print("An error has occurred: \(error.localizedDescription)")
            }
        }.resume()
        
    }
    
}
