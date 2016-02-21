//
//  ATM.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 4/3/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import CoreLocation


public class ATMRequestBuilder {
    public var requestType: HTTPType?
    public var atmId: String!
    public var radius: String?
    public var latitude: Float?
    public var longitude: Float?
}

public class ATMRequest {
    private var request: NSMutableURLRequest?
    private var builder: ATMRequestBuilder!
    
    public convenience init?(block: (ATMRequestBuilder -> Void)) {
        let initializingBuilder = ATMRequestBuilder()
        block(initializingBuilder)
        self.init(builder: initializingBuilder)
    }
    
    private init?(builder: ATMRequestBuilder) {
        self.builder = builder
        if (builder.requestType != HTTPType.GET) {
            NSLog("You can only make a GET request for ATMs")
            return nil
        }
        
        let requestString = buildRequestUrl();
        
        buildRequest(requestString);
        
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)/atms"
        if (builder.atmId != nil) {
            requestString += "/\(builder.atmId)?"
        }
        requestString += validateLocationSearchParameters()
        requestString += "key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    private func validateLocationSearchParameters() -> String {
        if (builder.latitude != nil && builder.longitude != nil && builder.radius != nil) {
            let locationSearchParameters = "lat=\(builder.latitude!)&lng=\(builder.longitude!)&rad=\(builder.radius!)"
            return "?"+locationSearchParameters+"&"
        }
        else if !(builder.latitude == nil && builder.longitude == nil && builder.radius == nil) {
            NSLog("To search for ATMs by location, you must provide latitude, longitude, and radius.")
            NSLog("You provided lat:\(builder.latitude) long:\(builder.longitude) radius:\(builder.radius)")
        }
        return ""
    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest
    {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request!.HTTPMethod = builder.requestType!.rawValue
        self.request!.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request!
    }
    
    //Method for sending the request
    
    public func send(completion: ((ATMResult) -> Void)?)
    {
        NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler:{(data, response, error) -> Void in
            if error != nil {
                NSLog(error!.description)
                return
            }
            if (completion == nil) {
                return
            }
            
            let result = ATMResult(data: data!)
            completion!(result)
            
        }).resume()
    }
}


public struct ATMResult
{
    private var dataItem:ATM?
    private var dataArray:Array<ATM>?
    private init(data:NSData) {
        let parsedObject: AnyObject? = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Dictionary<String,AnyObject>
        
        if let results = parsedObject as? NSDictionary {

            if let atmsDict = results["data"] as? [Dictionary<String, AnyObject>] {
                dataArray = []
                dataItem = nil
                for atm in atmsDict {
                    dataArray?.append(ATM(data: atm))
                }
            } else {
                dataArray = nil
               
                //If there is an error message, the json will parse to a dictionary, not an array
                if let message:AnyObject = results["message"] {
                    NSLog(message.description!)
                    if let reason:AnyObject = results["culprit"] {
                        NSLog("Reasons:\(reason.description)")
                        return
                    } else {
                        return
                    }
                }
                
                dataItem = ATM(data: results as! Dictionary<String, AnyObject>)

            }
        }
    }
    
    public func getATM() -> ATM? {
        if (dataItem == nil) {
            NSLog("No single data item found. If you were intending to get multiple items, try getAllATMs()");
        }
        return dataItem
    }
    
    public func getAllATMs() -> Array<ATM>? {
        if (dataArray == nil) {
            NSLog("No array of data items found. If you were intending to get one single item, try getATM()");
        }
        return dataArray
    }
}

public class ATM {
    
    public let atmId:String
    public let name:String
    public let languageList:Array<String>
    public let address:Address
    public let geocode:CLLocation
    public let amountLeft:Int
    public let accessibility: Bool
    public let hours: Array<String>
    
    internal init(data:Dictionary<String,AnyObject>) {
        self.atmId = data["_id"] as! String
        self.name = data["name"] as! String
        self.languageList = data["language_list"] as! Array<String>
        self.address = Address(data:data["address"] as! Dictionary<String,AnyObject>)
        self.amountLeft = data["amount_left"] as! Int
        self.accessibility = data["accessibility"] as! Bool
        self.hours = data["hours"] as! Array<String>
        
        var geocodeDict = data["geocode"] as! Dictionary<String, Double>
        self.geocode = CLLocation(latitude: geocodeDict["lat"]!, longitude: geocodeDict["lng"]!)
        
        
    }
}
