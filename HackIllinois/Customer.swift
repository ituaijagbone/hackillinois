//
//  Customer.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 4/3/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation



public class CustomerRequestBuilder {
    public var requestType: HTTPType?
    public var customerId: String?
    public var accountId: String?
    public var address: Address?
    public var firstName: String?
    public var lastName: String?
}

public class CustomerRequest {
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var builder: CustomerRequestBuilder!
    
    public convenience init?(block: (CustomerRequestBuilder -> Void)) {
        let initializingBuilder = CustomerRequestBuilder()
        block(initializingBuilder)
        self.init(builder: initializingBuilder)
    }
    
    private init?(builder: CustomerRequestBuilder)
    {
        self.builder = builder
        if (builder.requestType == HTTPType.DELETE) {
            NSLog("Cannot POST or DELETE a customer")
            return nil
        }
        
        if ((builder.firstName == nil || builder.lastName == nil || builder.address == nil) && builder.requestType == HTTPType.POST) {
            NSLog("DELETE requires firsName, lastName and Address")
            return nil
        }

        if (builder.customerId == nil && builder.requestType == HTTPType.PUT) {
            NSLog("PUT requires a customer id")
            return nil
        }
        
        let requestString = buildRequestUrl();
        
        self.request = buildRequest(requestString);
        
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)"
        
        if (builder.accountId != nil) {
            self.getsArray = false
            requestString += "/accounts/\(builder.accountId!)/customer"
        } else if (builder.customerId != nil) {
            self.getsArray = false
            requestString += "/customers/\(builder.customerId!)"
        } else {
            requestString += "/customers"
        }

        if (builder.requestType == HTTPType.POST) {
            requestString = "\(baseString)/customers"
        }

        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        return requestString
    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest {
        
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = builder.requestType!.rawValue
        request = addParamsToRequest(request);
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        return request
    }
    
    private func addParamsToRequest(request:NSMutableURLRequest) -> NSMutableURLRequest {
        var params:Dictionary<String, AnyObject> = [:]
        var err: NSError?
        
        if (builder.requestType == HTTPType.POST) {
            let address = ["street_number":builder.address!.streetNumber, "street_name":builder.address!.streetName, "city":builder.address!.city, "state":builder.address!.state, "zip":builder.address!.zipCode]
            params = ["first_name":builder.firstName!, "last_name":builder.lastName!, "address":address]
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch let error as NSError {
                if err == nil{
                err = error
                request.HTTPBody = nil
                }
            }
            
        }

        if (builder.requestType == HTTPType.PUT) {
            if let address = builder.address {
                params["address"] = address.toDict()
                do {
                    request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
                } catch let error as NSError {
                    err = error
                    request.HTTPBody = nil
                }
            }
        }

        return request
    }
    
    //Method for sending the request
    
    public func send(completion: ((CustomerResult) -> Void)?) {
        
        NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler:{(data, response, error) -> Void in
            if error != nil {
                NSLog(error!.description)
                return
            }
            if (completion == nil) {
                return
            }
            
            let result = CustomerResult(data: data!)
            completion!(result)
            
        }).resume()
    }
}


public struct CustomerResult {
    private var dataItem:Customer?
    private var dataArray:Array<Customer>?
    internal init(data:NSData) {
        //var parseError: NSError?
        if let parsedObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Array<Dictionary<String,AnyObject>> {
            
            dataArray = []
            dataItem = nil
            for customer in parsedObject {
                dataArray?.append(Customer(data: customer))
            }
        }
        if let parsedObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Dictionary<String,AnyObject> {
            dataArray = nil
            
            //If there is an error message, the json will parse to a dictionary, not an array
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
                    dataArray?.append(Customer(data: transfer as! Dictionary<String, AnyObject>))
                }
                return
            }

            dataItem = Customer(data: parsedObject)
        }
        
        if (dataItem == nil && dataArray == nil) {
            let datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
            NSLog("Could not parse data: \(datastring)")
        }
    }
    
    public func getCustomer() -> Customer? {
        if (dataItem == nil) {
            NSLog("No single data item found. If you were intending to get multiple items, try getAllCustomers()");
        }
        return dataItem
    }
    
    public func getAllCustomers() -> Array<Customer>? {
        if (dataArray == nil) {
            NSLog("No array of data items found. If you were intending to get one single item, try getCustomer()");
        }
        return dataArray
    }
}

public class Customer {
    public let firstName:String
    public let lastName:String

    public let address:Address
    public let accountIds: Array<String>?
    public let customerId:String
    
    internal init(data:Dictionary<String,AnyObject>) {
        self.firstName = data["first_name"] as! String
        self.lastName = data["last_name"] as! String
        self.address = Address(data:data["address"] as! Dictionary<String,AnyObject>)
        self.accountIds = data["account_ids"] as? Array<String>
        self.customerId = data["_id"] as! String
    }
    
    
}
