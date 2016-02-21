//
//  Account.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 4/3/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation

public enum AccountType : String {
    case CREDIT_CARD = "Credit Card"
    case SAVINGS = "Savings"
    case CHECKING = "Checking"
}

public class AccountRequestBuilder {
    public var requestType: HTTPType?
    public var accountId: String?
    public var nickname: String?
    public var accountType: AccountType?
    public var rewards: Int?
    public var balance: Int?
    public var customerId: String?
}

public class AccountRequest {
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var builder: AccountRequestBuilder!
    
    public convenience init?(block: (AccountRequestBuilder -> Void)) {
        let initializingBuilder = AccountRequestBuilder()
        block(initializingBuilder)
        self.init(builder: initializingBuilder)
    }
    
    private init?(builder: AccountRequestBuilder)
    {
        self.builder = builder
        
        if (builder.accountId == nil && builder.requestType != HTTPType.GET && builder.requestType != HTTPType.POST) {
            NSLog("PUT/DELETE require an account id")
            return nil
        }
        if (builder.requestType == HTTPType.POST && builder.customerId == nil) {
            NSLog("POST requires a customer ID")
            return nil
        }
        
        let requestString = buildRequestUrl();
        
        self.request = buildRequest(requestString);
        
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)/accounts"
        if (builder.accountId != nil) {
            self.getsArray = false
            requestString += "/\(builder.accountId!)"
        }
        
        if (builder.customerId != nil) {
            requestString = "\(baseString)/customers/\(builder.customerId!)/accounts"
        }
        
        if (builder.requestType == HTTPType.POST) {
            requestString = "\(baseString)/customers/\(builder.customerId!)/accounts"
        }
        
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        if (builder.requestType == HTTPType.GET && builder.accountId == nil && builder.accountType != nil) {
            var typeParam = builder.accountType!.rawValue
            typeParam = typeParam.stringByReplacingOccurrencesOfString(" ", withString: "%20")
            requestString += "&type=\(typeParam)"
        }
        
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
        var params:Dictionary<String, AnyObject>= [:]
        var err: NSError?

        if (builder.requestType == HTTPType.POST) {
            params = ["nickname":builder.nickname!, "type":builder.accountType!.rawValue, "balance":builder.balance!,"rewards":builder.rewards!]
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch let error as NSError {
                if err == nil {
                err = error
                request.HTTPBody = nil
                }
            }
            
        }
        if (builder.requestType == HTTPType.PUT) {
            if let nickname = builder.nickname {
                params["nickname"] = nickname
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
    
    public func send(completion: ((AccountResult) -> Void)?) {
        
        NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler:{(data, response, error) -> Void in
            if error != nil {
                NSLog(error!.description)
                return
            }
            if (completion == nil) {
                return
            }
            
            let result = AccountResult(data: data!)
            completion!(result)
            
        }).resume()
    }
}


public struct AccountResult {
    private var dataItem:Account?
    private var dataArray:Array<Account>?
    internal init(data:NSData) {
        //var parseError: NSError?
        if let parsedObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Array<Dictionary<String,AnyObject>> {
            
            dataArray = []
            dataItem = nil
            for account in parsedObject {
                dataArray?.append(Account(data: account))
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
                    dataArray?.append(Account(data: transfer as! Dictionary<String, AnyObject>))
                }
                return
            }
            
            dataItem = Account(data: parsedObject)
        }
        if (dataArray == nil) && dataItem == nil {
            if (data.description == "<>") {
                NSLog("Account delete Successful")
            }
        }
    }
    
    public func getAccount() -> Account? {
        if (dataItem == nil) {
            NSLog("No single data item found. If you were intending to get multiple items, try getAllAccounts()");
        }
        return dataItem
    }
    
    public func getAllAccounts() -> Array<Account>? {
        if (dataArray == nil) {
            NSLog("No array of data items found. If you were intending to get one single item, try getAccount()");
        }
        return dataArray
    }
}

public class Account {
    
    public let accountType:String
    public let rewards:Int
    public let balance:Int
    public var billIds:Array<String>? = nil
    public let customerId:String
    public let accountId:String
    public let nickname:String
    
    internal init(data:Dictionary<String,AnyObject>) {
        self.accountType = data["type"] as! String
        self.rewards = data["rewards"] as! Int
        self.balance = data["balance"] as! Int
        self.billIds = data["bill_ids"] as? Array<String>
        self.customerId = data["customer_id"] as! String
        self.accountId = data["_id"] as! String
        self.nickname = data["nickname"] as! String
    }
}
