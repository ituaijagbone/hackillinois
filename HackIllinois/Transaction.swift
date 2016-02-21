//
//  Transaction.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 4/3/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation

public enum TransactionMedium : String {
    case BALANCE = "balance"
    case REWARDS = "rewards"
}

public enum TransactionType : String {
    case PAYEE = "payee"
    case PAYER = "payer"
}


public class TransactionRequestBuilder {
    public var requestType: HTTPType?
    public var accountId: String?
    public var transactionId: String?
    public var transactionType: TransactionType?
    public var payeeId: String?
    public var amount: Int?
    public var description: String?
    public var transactionMedium:TransactionMedium?
}

public class TransactionRequest {
    
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var builder: TransactionRequestBuilder!
    
    public convenience init?(block: (TransactionRequestBuilder -> Void)) {
        let initializingBuilder = TransactionRequestBuilder()
        block(initializingBuilder)
        self.init(builder: initializingBuilder)
    }
    
    private init?(builder: TransactionRequestBuilder)
    {
        self.builder = builder
        
        if (builder.accountId == nil) {
            NSLog("Transactions require an account id")
            return nil
        }
        if (builder.transactionId == nil && builder.requestType != HTTPType.GET && builder.requestType != HTTPType.POST) {
            NSLog("PUT/DELETE require a transaction id")
            return nil
        }
        
        let requestString = buildRequestUrl()
        buildRequest(requestString)
        
    }
        
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)/accounts/\(builder.accountId!)/transactions"
        if (builder.transactionId != nil) {
            self.getsArray = false
            requestString += "/\(builder.transactionId!)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        if (builder.requestType == HTTPType.GET && builder.accountId == nil && builder.transactionType != nil) {
            requestString += "&type=\(builder.transactionType!)"
        }
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
        var params:Dictionary<String, AnyObject>= [:]
        var err: NSError?
        
        if (builder.requestType == HTTPType.POST) {
            params = ["payee_id":builder.payeeId!,"amount":builder.amount!,"medium":builder.transactionMedium!.rawValue]
            if let description = builder.description {
                params["description"] = description
            }
            do {
                self.request!.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch let error as NSError {
                if err == nil {
                err = error
                self.request!.HTTPBody = nil
                }
            }
        }
        if (builder.requestType == HTTPType.PUT) {
            if let payeeId = builder.payeeId {
                params["payee_id"] = payeeId
            }
            if let transType = builder.transactionMedium {
                params["medium"] = transType.rawValue
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
                if err == nil {
                err = error
                self.request!.HTTPBody = nil
                }
            }
        }
    }

    
    //Sending the request
    
    public func send(completion completion: ((TransactionResult) -> Void)?) {
        
        NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler:{(data, response, error) -> Void in
            if error != nil {
                NSLog(error!.description)
                return
            }
            if (completion == nil) {
                return
            }
            
            let result = TransactionResult(data: data!)
            completion!(result)
            
        }).resume()
    }
}


public struct TransactionResult {
    private var dataItem:Transaction?
    private var dataArray:Array<Transaction>?
    internal init(data:NSData) {
        if let parsedObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Array<Dictionary<String,AnyObject>> {
            
            dataArray = []
            dataItem = nil
            for transaction in parsedObject {
                dataArray?.append(Transaction(data: transaction))
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
            
            dataItem = Transaction(data: parsedObject)
        }
        
        if (dataItem == nil && dataArray == nil) {
            let datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
            if (data.description == "<>") {
                NSLog("Transaction delete successful")
            } else {
                NSLog("Could not parse data: \(datastring)")
            }
        }
    }
    
    public func getTransaction() -> Transaction? {
        if (dataItem == nil) {
            NSLog("No single data item found. If you were intending to get multiple items, try getAllTransactions()");
        }
        return dataItem
    }
    
    public func getAllTransactions() -> Array<Transaction>? {
        if (dataArray == nil) {
            NSLog("No array of data items found. If you were intending to get one single item, try getTransaction()");
        }
        return dataArray
    }
}

public class Transaction {
    
    public let medium:TransactionMedium
    public let payeeId:String?
    public let amount:Int
    public let transactionId:String
    public let status:String
    public let payerId:String?
    public var transactionDate:NSDate? = nil
    public let description:String
    public let type:String
    
    internal init(data:Dictionary<String,AnyObject>) {
        self.medium = TransactionMedium(rawValue:data["medium"] as! String)!
        self.payeeId = data["payee_id"] as? String
        self.amount = data["amount"] as! Int
        self.transactionId = data["_id"] as! String
        self.status = data["status"] as! String
        self.payerId  = data["payer_id"] as? String
        self.description = data["description"] as! String
        let transactionDateString = data["transaction_date"] as? String
        if let str = transactionDateString {
            if let date = dateFormatter.dateFromString(str) {
                self.transactionDate = date }
            else {
                self.transactionDate = NSDate()
            }
        }
        self.type = data["type"] as! String
    }
}
