//
//  Withdrawal.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 4/3/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation

public class WithdrawalRequestBuilder {
    public var requestType: HTTPType?
    public var accountId: String!
    
    public var withdrawalMedium: TransactionMedium?
    public var amount: Int?
    public var withdrawalId: String!
    public var description: String?
    public var withdrawalDate: String!
    public var status: String!

}

public class WithdrawalRequest {
    
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var builder: WithdrawalRequestBuilder!
    
    public convenience init?(block: (WithdrawalRequestBuilder -> Void)) {
        let initializingBuilder = WithdrawalRequestBuilder()
        block(initializingBuilder)
        self.init(builder: initializingBuilder)
    }
    
    private init?(builder: WithdrawalRequestBuilder)
    {
        self.builder = builder
        
        if (builder.withdrawalId == nil && (builder.requestType == HTTPType.PUT || builder.requestType == HTTPType.DELETE)) {
            NSLog("PUT/DELETE require a withdrawalId")
            return nil
        }
        
        if ((builder.accountId == nil || builder.withdrawalMedium == nil || builder.amount == nil) && builder.requestType == HTTPType.POST) {
            if (builder.accountId == nil) {
                NSLog("POST requires accountId")
            }
            if (builder.amount == nil) {
                NSLog("POST requires amount")
            }
            if (builder.withdrawalMedium == nil) {
                NSLog("POST requires withdrawalMedium")
            }
            
            return nil
        }
        
        let requestString = buildRequestUrl()
        buildRequest(requestString)
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)"
        
        if (builder.requestType == HTTPType.PUT) {
            requestString += "/withdrawals/\(builder.withdrawalId)?"
            requestString += "key=\(NSEClient.sharedInstance.getKey())"
            return requestString
        }
        
        if (builder.requestType == HTTPType.DELETE) {
            requestString += "/withdrawals/\(builder.withdrawalId)?"
            requestString += "key=\(NSEClient.sharedInstance.getKey())"
            return requestString
        }
        
        if (builder.accountId != nil) {
            requestString += "/accounts/\(builder.accountId!)/withdrawals"
        }
        if (builder.withdrawalId != nil) {
            self.getsArray = false
            requestString += "/withdrawals/\(builder.withdrawalId!)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        return requestString

    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request!.HTTPMethod = builder.requestType!.rawValue
        
        addParamsToRequest();
        
        self.request!.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request!
    }
    
    private func addParamsToRequest() {
        var params:Dictionary<String, AnyObject> = [:]
        var err: NSError?
        
        if (builder.requestType == HTTPType.POST) {
            params = ["medium":builder.withdrawalMedium!.rawValue, "amount":builder.amount!]
            if let description = builder.description {
                params["description"] = description
            }
            if let date = builder.withdrawalDate {
                params["transaction_date"] = date
            }
            if let status = builder.status {
                params["status"] = status
            }
            do {
                self.request!.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch let error as NSError {
                if err == nil{
                    err = error
                    self.request!.HTTPBody = nil
                }
            }
            
        }
        if (builder.requestType == HTTPType.PUT) {
            if let medium = builder.withdrawalMedium {
                params["medium"] = medium.rawValue
            }
            if let amount = builder.amount {
                params["amount"] = amount
            }
            if let description = builder.description {
                params["description"] = description
            }
            do {
                self.request!.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch let error as NSError {
                err = error
                self.request!.HTTPBody = nil
            }
        }
    }
    
    
    //Sending the request
    
    public func send(completion completion: ((WithdrawalResult) -> Void)?) {
        
        NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler:{(data, response, error) -> Void in
            if error != nil {
                NSLog(error!.description)
                return
            }
            if (completion == nil) {
                return
            }
            
            let result = WithdrawalResult(data: data!)
            completion!(result)
            
        }).resume()
    }
}


public struct WithdrawalResult {
    private var dataItem:Withdrawal?
    private var dataArray:Array<Withdrawal>?
    internal init(data:NSData) {
        if let parsedObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Array<Dictionary<String,AnyObject>> {
            
            dataArray = []
            dataItem = nil
            for withdrawal in parsedObject {
                dataArray?.append(Withdrawal(data: withdrawal))
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
            
            if let parsedObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Dictionary<String,AnyObject> {
                dataArray = nil
                
                if let results:Array<AnyObject> = parsedObject["results"] as? Array<AnyObject> {
                    dataArray = []
                    dataItem = nil
                    for transfer in results {
                        dataArray?.append(Withdrawal(data: transfer as! Dictionary<String, AnyObject>))
                    }
                    return
                }
            }
            
            dataItem = Withdrawal(data: parsedObject)
        }
        if (dataItem == nil && dataArray == nil) {
            let datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
            if (data.description == "<>") {
                NSLog("Withdrawal delete successful")
            } else {
                NSLog("Could not parse data: \(datastring)")
            }
        }
    }
    
    public func getWithdrawal() -> Withdrawal? {
        if (dataItem == nil) {
            NSLog("No single data item found. If you were intending to get multiple items, try getAllWithdrawals()");
        }
        return dataItem
    }
    
    public func getAllWithdrawals() -> Array<Withdrawal>? {
        if (dataArray == nil) {
            NSLog("No array of data items found. If you were intending to get one single item, try getWithdrawal()");
        }
        return dataArray
    }
}

public class Withdrawal {
    public let status:String!
    public let medium:TransactionMedium
    public let payerId:String!
    public let amount:Int!
    public let type:String!
    public var transactionDate:NSDate? = nil
    public let description:String!
    public let withdrawalId:String!
    
    internal init(data:Dictionary<String,AnyObject>) {
        self.status = data["status"] as? String
        self.medium = TransactionMedium(rawValue:data["medium"] as! String)!
        self.payerId = data["payer_id"] as? String
        self.amount = data["amount"] as! Int
        self.type = data["type"] as! String
        let transactionDateString = data["transaction_date"] as? String
        if let str = transactionDateString {
            if let date = dateFormatter.dateFromString(str) {
                self.transactionDate = date }
            else {
                self.transactionDate = NSDate()
            }
        }
        self.description = data["description"] as! String
        self.withdrawalId = data["_id"] as! String
    }
}

