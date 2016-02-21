//
//  Address.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 5/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation

public class Address:NSObject {
    public let streetNumber:String
    public let streetName:String
    public let city:String
    public let state:String
    public let zipCode:String
    
    internal init(data:Dictionary<String,AnyObject>) {
        if let street = data["street_name"] as? String{
            streetName = street
        } else {
            streetName = ""
        }

        if let streetNum = data["street_number"] as? String{
            streetNumber = streetNum
        } else {
            streetNumber = ""
        }

        if let cityName = data["city"] as? String{
            city = cityName
        } else {
            city = ""
        }

        if let stateString = data["state"] as? String{
            state = stateString
        } else {
            state = ""
        }
        
        if let zip = data["zip"] as? String{
            zipCode = zip
        } else {
            zipCode = ""
        }
    }
    
    public init(streetName:String, streetNumber:String, city:String, state:String, zipCode:String) {
        self.streetName = streetName
        self.streetNumber = streetNumber
        self.city = city
        self.state = state
        self.zipCode = zipCode
    }
    
    internal func toDict() -> Dictionary<String,AnyObject> {
        let dict = ["street_name":streetName,"street_number":streetNumber,"state":state, "city":city, "zip":zipCode]
        return dict
    }
}