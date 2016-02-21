//
//  Bill.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 4/3/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation

public enum BillStatus : String {
    case PENDING = "pending"
    case RECURRING = "recurring"
    case CANCELLED = "cancelled"
    case COMPLETED = "completed"
}

public class BillRequestBuilder {
    public var requestType: HTTPType?
    public var billId: String?
    public var status: BillStatus?
    public var payee: String?
    public var nickname: String?
    public var paymentDate: NSDate?
    public var recurringDate: Int?
    public var paymentAmount: Int?
    public var accountId: String!
    public var customerId: String!
}


public class BillRequest {
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var builder: BillRequestBuilder!
    
    public convenience init?(block: (BillRequestBuilder -> Void)) {
        let initializingBuilder = BillRequestBuilder()
        block(initializingBuilder)
        self.init(builder: initializingBuilder)
    }
    
    private init?(builder: BillRequestBuilder)
    {
        self.builder = builder
        if (builder.accountId == nil) {
            NSLog("Please provide an account ID for bill request")
        }
        if (builder.billId == nil && builder.requestType != HTTPType.GET && builder.requestType != HTTPType.POST) {
            NSLog("PUT/DELETE require a bill id")
            return nil
        }
        
        let isValid = validateBuilder(builder)
        if (!isValid) {
            return nil
        }
        
        let requestString = buildRequestUrl();
        
        buildRequest(requestString);
        
    }
    
    private func validateBuilder(builder:BillRequestBuilder) -> Bool {
        if builder.status == BillStatus.RECURRING {
            if (builder.paymentDate != nil || builder.recurringDate == nil) {
                NSLog("Recurring payment must have paymentDate of nil, has \(builder.paymentDate). Must have non-nil recurring date, has \(builder.recurringDate)")
                return false
            }
        }
        else if builder.status == BillStatus.PENDING {
            if (builder.paymentDate == nil || builder.recurringDate != nil) {
                NSLog("Pending payment must have non-nil, has \(builder.paymentDate). Must have nil recurring date, has \(builder.recurringDate)")
                return false
            }
        }
        return true
    }
    
    //Methods for building the request.
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)"
        if (builder.customerId != nil) {
            requestString += "/customers/\(builder.customerId)/bills"
        } else if (builder.billId != nil) {
            self.getsArray = false
            requestString += "/bills/\(builder.billId!)"
        } else if (builder.accountId != nil) {
            requestString += "/accounts/\(builder.accountId)/bills"
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
        var params:Dictionary<String, AnyObject>= [:]
        var err: NSError?
        
        if (builder.requestType == HTTPType.POST) {
            params = ["nickname":builder.nickname!, "status":builder.status!.rawValue, "payee":builder.payee!,"payment_amount":builder.paymentAmount!]
            
            if (builder.paymentDate != nil) {
                params["payment_date"] = dateFormatter.stringFromDate(builder.paymentDate!)
            }
            if (builder.recurringDate != nil) {
                params["recurring_date"] = builder.recurringDate
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
            if let nickname = builder.nickname {
                params["nickname"] = nickname
            }
            if (builder.paymentDate != nil) {
                params["payment_date"] = dateFormatter.stringFromDate(builder.paymentDate!)
            }
            if (builder.recurringDate != nil) {
                params["recurring_date"] = builder.recurringDate
            }
            if let status = builder.status {
                params["status"] = status.rawValue
            }
            if let payee = builder.payee {
                params["payee"] = payee
            }
            if let paymentAmount = builder.paymentAmount {
                params["payment_amount"] = paymentAmount
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
    //Method for sending the request
    
    public func send(completion completion: ((BillResult) -> Void)?) {
        
        NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler:{(data, response, error) -> Void in
            if error != nil {
                NSLog(error!.description)
                return
            }
            if (completion == nil) {
                return
            }
            
            let result = BillResult(data: data!)
            completion!(result)
            
        }).resume()
    }
}


public struct BillResult {
    private var dataItem:Bill?
    private var dataArray:Array<Bill>?
    internal init(data:NSData) {
        //var parseError: NSError?
        if let parsedObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Array<Dictionary<String,AnyObject>> {
            dataArray = []
            dataItem = nil
            for bill in parsedObject {
                dataArray?.append(Bill(data: bill))
            }
            return
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
                    dataArray?.append(Bill(data: transfer as! Dictionary<String, AnyObject>))
                }
                return
            }

            dataItem = Bill(data: parsedObject)
        }
        if (dataItem == nil && dataArray == nil) {
            let datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
            if (data.description == "<>") {
                NSLog("Bill delete Successful")
            } else {
                NSLog("Could not parse data: \(datastring)")
            }
        }
    }
    
    public func getBill() -> Bill? {
        if (dataItem == nil) {
            NSLog("No single data item found. If you were intending to get multiple items, try getAllBills()");
        }
        return dataItem
    }
    
    public func getAllBills() -> Array<Bill>? {
        if (dataArray == nil) {
            NSLog("No array of data items found. If you were intending to get one single item, try getBill()");
        }
        return dataArray
    }
}

public class Bill {
    
    public let billId:String
    public let status:BillStatus
    public var nickname:String? = nil
    public var paymentDate:NSDate? = nil
    public var recurringDate:Int?
    public let paymentAmount: Int
    public var creationDate:NSDate?
    public var upcomingPaymentDate:NSDate? = nil
    
    internal init(data:Dictionary<String,AnyObject>) {
        
        self.billId = data["_id"] as! String
        self.status = BillStatus(rawValue: (data["status"] as! String))!
        self.nickname = data["nickname"] as? String
        let paymentDateString = data["payment_date"] as? String
        if let str = paymentDateString {
            self.paymentDate = dateFormatter.dateFromString(str)
        }
        if let recurring:Int = data["recurring_date"] as? Int {
            self.recurringDate = recurring
        }
        
        self.paymentAmount = data["payment_amount"] as! Int
        self.creationDate = dateFormatter.dateFromString(data["creation_date"] as! String)
        let upcomingDateString:String? = data["upcoming_payment_date"] as? String
        if let str = upcomingDateString {
            self.upcomingPaymentDate = dateFormatter.dateFromString(str)
        }
    }
}
