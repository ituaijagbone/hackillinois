//
//  Branch.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 4/3/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import CoreLocation


public class BranchRequestBuilder {
    public var requestType: HTTPType?
    public var branchId: String!
}

public class BranchRequest {
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var builder: BranchRequestBuilder!
    
    public convenience init?(block: (BranchRequestBuilder -> Void)) {
        let initializingBuilder = BranchRequestBuilder()
        block(initializingBuilder)
        self.init(builder: initializingBuilder)
    }
    
    private init?(builder: BranchRequestBuilder) {
        self.builder = builder
        if (builder.requestType != HTTPType.GET) {
            NSLog("You can only make a GET request for Branches")
            return nil
        }
        
        let requestString = buildRequestUrl();
        
        buildRequest(requestString);
        
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)/branches"
        if (builder.branchId != nil) {
            self.getsArray = false
            requestString += "/\(builder.branchId)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
                
        return requestString
    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest
    {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request!.HTTPMethod = builder.requestType!.rawValue
        self.request!.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request!
    }
    
    //Method for sending the request
    
    public func send(completion: ((BranchResult) -> Void)?)
    {
        NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler:{(data, response, error) -> Void in
            if error != nil {
                NSLog(error!.description)
                return
            }
            if (completion == nil) {
                return
            }
            
            let result = BranchResult(data: data!)
            completion!(result)
            
        }).resume()
    }
}


public struct BranchResult
{
    private var dataItem:Branch?
    private var dataArray:Array<Branch>?
    private init(data:NSData) {
        if let parsedObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Array<Dictionary<String,AnyObject>> {
            
            dataArray = []
            dataItem = nil
            for branch in parsedObject {
                dataArray?.append(Branch(data: branch))
            }
        }
        if let parsedObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Dictionary<String,AnyObject> {
            dataArray = nil
            dataItem = Branch(data: parsedObject)
        }
        if (dataItem == nil && dataArray == nil) {
            let datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
            NSLog("Could not parse data: \(datastring)")
        }
    }
    
    public func getBranch() -> Branch? {
        if (dataItem == nil) {
            NSLog("No single data item found. If you were intending to get multiple items, try getAllBranches()");
        }
        return dataItem
    }
    
    public func getAllBranches() -> Array<Branch>? {
        if (dataArray == nil) {
            NSLog("No array of data items found. If you were intending to get one single item, try getBranch()");
        }
        return dataArray
    }
}

public class Branch {
    
    public let branchId:String
    public let name:String
    public let address:Address
    public let phoneNumber: String
    public let hours: Array<String>
    
    init(data:Dictionary<String,AnyObject>) {
        self.branchId = data["_id"] as! String
        self.name = data["name"] as! String
        self.address = Address(data:data["address"] as! Dictionary<String,AnyObject>)
        self.phoneNumber = data["phone_number"] as! String
        self.hours = data["hours"] as! Array<String>
    }
}
