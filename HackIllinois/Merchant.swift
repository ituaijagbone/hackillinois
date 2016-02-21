//
//  Merchant.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. (CONT) on 9/1/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import CoreLocation


public class MerchantRequestBuilder {
    public var requestType: HTTPType!
    public var merchantId: String!
    public var radius: String!
    public var latitude: Float!
    public var longitude: Float!
    public var name: String!
    public var address: Address!
}

public class MerchantRequest {
    private var request: NSMutableURLRequest?
    private var builder: MerchantRequestBuilder!
    
    public convenience init?(block: (MerchantRequestBuilder -> Void)) {
        let initializingBuilder = MerchantRequestBuilder()
        block(initializingBuilder)
        self.init(builder: initializingBuilder)
    }
    
    private init?(builder: MerchantRequestBuilder) {
        self.builder = builder
        if (builder.requestType == HTTPType.DELETE) {
            NSLog("You can't delete Merchants")
            return nil
        }
        
        if (builder.merchantId == nil && builder.requestType == HTTPType.PUT) {
            NSLog("PUT requires a customer id")
            return nil
        }

        let requestString = buildRequestUrl();
        
        buildRequest(requestString);
        
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)/merchants"
        if (builder.requestType == HTTPType.PUT) {
            requestString += "/\(builder.merchantId)?"
            requestString += "key=\(NSEClient.sharedInstance.getKey())"
            return requestString
        }

        if (builder.requestType == HTTPType.POST) {
            requestString += "?key=\(NSEClient.sharedInstance.getKey())"
            return requestString            
        }
        
        if (builder.merchantId != nil) {
            requestString += "/\(builder.merchantId)?"
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
            NSLog("To search for Merchants by location, you must provide latitude, longitude, and radius.")
            NSLog("You provided lat:\(builder.latitude) long:\(builder.longitude) radius:\(builder.radius)")
        }
        return ""
    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest {
        
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request!.HTTPMethod = builder.requestType!.rawValue
        self.request = addParamsToRequest(request!);
        self.request!.setValue("application/json", forHTTPHeaderField: "content-type")
        return request!
    }
    
    private func addParamsToRequest(request:NSMutableURLRequest) -> NSMutableURLRequest {
        var params:Dictionary<String, AnyObject> = [:]
        var err: NSError?
        
        if (builder.requestType == HTTPType.PUT) {
            if let name = builder.name {
                params["name"] = name
            }
            
            if let _ = builder.address {
                let address2 = ["street_number":builder.address!.streetNumber, "street_name":builder.address!.streetName, "city":builder.address!.city, "state":builder.address!.state, "zip":builder.address!.zipCode]
                params["address"] = address2
            }
            if (builder.latitude != nil && builder.longitude != nil) {
                let geo = ["lat":builder.latitude, "lng":builder.longitude]
                params["geocode"] = geo
            } else {
                print("Latitude and Longitude must be set to update the geolocation\n", terminator: "")
            }

            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch let error as NSError {
                if err == nil {
                err = error
                request.HTTPBody = nil
                }
            }
            
        }
        
        if (builder.requestType == HTTPType.POST) {
            
            if let name = builder.name {
                params["name"] = name
            }
            
            if let _ = builder.address {
                let address2 = ["street_number":builder.address!.streetNumber, "street_name":builder.address!.streetName, "city":builder.address!.city, "state":builder.address!.state, "zip":builder.address!.zipCode]
                params["address"] = address2
            }
            if (builder.latitude != nil && builder.longitude != nil) {
                let geo = ["lat":builder.latitude, "lng":builder.longitude]
                params["geocode"] = geo
            } else {
                print("Latitude and Longitude must be set to set the geolocation", terminator: "")
            }
            
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch let error as NSError {
                if err == nil {
                err = error
                request.HTTPBody = nil
                }
            }
        }
        
        return request
    }

    //Method for sending the request
    
    public func send(completion: ((MerchantResult) -> Void)?)
    {
        NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler:{(data, response, error) -> Void in
            if error != nil {
                NSLog(error!.description)
                return
            }
            if (completion == nil) {
                return
            }
            
            let result = MerchantResult(data: data!)
            completion!(result)
            
        }).resume()
    }
}


public struct MerchantResult
{
    private var dataItem:Merchant?
    private var dataArray:Array<Merchant>?
    internal init(data:NSData) {
        //var parseError: NSError?
       
        if let parsedObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Array<Dictionary<String,AnyObject>> {
            dataArray = []
            dataItem = nil
            for merchant in parsedObject {
                dataArray?.append(Merchant(data: merchant))
            }
        }
        
        if let parsedObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Dictionary<String,AnyObject> {
            
            let results = parsedObject
            
            if let message:AnyObject = parsedObject["message"] {
                NSLog(message.description!)
                if let reason:AnyObject = parsedObject["culprit"] {
                    NSLog("Reasons:\(reason.description)")
                    return
                } else {
                    return
                }
            }
            
            if let results:Array<AnyObject> = parsedObject["results"] as? Array<AnyObject> {
                dataArray = []
                dataItem = nil
                for transfer in results {
                    dataArray?.append(Merchant(data: transfer as! Dictionary<String, AnyObject>))
                }
                return
            }
            
            if let MerchantsDict = results["data"] as? [Dictionary<String, AnyObject>] {
                dataArray = []
                dataItem = nil
                for merchant in MerchantsDict {
                    dataArray?.append(Merchant(data: merchant))
                }
            } else {
                dataArray = nil
                dataItem = Merchant(data: results as Dictionary<String, AnyObject>)
                
            }
            
        }
    }
    
    public func getMerchant() -> Merchant? {
        if (dataItem == nil) {
            NSLog("No single data item found. If you were intending to get multiple items, try getAllMerchants()");
        }
        return dataItem
    }
    
    public func getAllMerchants() -> Array<Merchant>? {
        if (dataArray == nil) {
            NSLog("No array of data items found. If you were intending to get one single item, try getMerchant()");
        }
        return dataArray
    }
}

public class Merchant {
    
    public let merchantId:String
    public let name:String
    public let address:Address
    public let geocode:CLLocation
    
    internal init(data:Dictionary<String,AnyObject>) {
        self.merchantId = data["_id"] as! String
        self.name = data["name"] as! String
        self.address = Address(data:data["address"] as! Dictionary<String,AnyObject>)
        var geocodeDict = data["geocode"] as! Dictionary<String, Double>
        self.geocode = CLLocation(latitude: geocodeDict["lat"]!, longitude: geocodeDict["lng"]!)
    }
}
