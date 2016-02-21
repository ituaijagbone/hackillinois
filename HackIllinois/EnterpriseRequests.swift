//
//  EnterpriseRequests.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 5/19/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation

/**********
Transfer
***********/

public class EnterpriseTransferRequest {
    
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var transactionId: String?
    
    public convenience init?() {
        self.init(transactionId: nil)
    }
    
    public init?(transactionId: String?)
    {
        self.transactionId = transactionId
        let requestString = buildRequestUrl()
        buildRequest(requestString)
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)/enterprise/transfers"
        if (transactionId != nil) {
            self.getsArray = false
            requestString += "/\(transactionId!)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request!.HTTPMethod = HTTPType.GET.rawValue
        
        self.request!.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request!
    }
    //Sending the request
    
    public func send(completion: ((TransferResult) -> Void)?) {
        
        NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler:{(data, response, error) -> Void in
            if error != nil {
                NSLog(error!.description)
                return
            }
            if (completion == nil) {
                return
            }
            
            let result = TransferResult(data: data!)
            completion!(result)
            
        }).resume()
    }
}


/**********
Deposit
***********/

public class EnterpriseDepositRequest {
    
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var transactionId: String?
    
    public convenience init?() {
        self.init(transactionId: nil)
    }
    
    public init?(transactionId: String?)
    {
        self.transactionId = transactionId
        let requestString = buildRequestUrl()
        buildRequest(requestString)
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)/enterprise/deposits"
        if (transactionId != nil) {
            self.getsArray = false
            requestString += "/\(transactionId!)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request!.HTTPMethod = HTTPType.GET.rawValue
        
        self.request!.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request!
    }
    //Sending the request
    
    public func send(completion: ((DepositResult) -> Void)?) {
        
        NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler:{(data, response, error) -> Void in
            if error != nil {
                NSLog(error!.description)
                return
            }
            if (completion == nil) {
                return
            }
            
            let result = DepositResult(data: data!)
            completion!(result)
            
        }).resume()
    }
}

/**********
Withdrawal
***********/

public class EnterpriseWithdrawalRequest {
    
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var transactionId: String?
    
    public convenience init?() {
        self.init(transactionId: nil)
    }
    
    public init?(transactionId: String?)
    {
        self.transactionId = transactionId
        let requestString = buildRequestUrl()
        buildRequest(requestString)
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)/enterprise/withdrawals"
        if (transactionId != nil) {
            self.getsArray = false
            requestString += "/\(transactionId!)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request!.HTTPMethod = HTTPType.GET.rawValue
        
        self.request!.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request!
    }
    //Sending the request
    
    public func send(completion: ((WithdrawalResult) -> Void)?) {
        
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

/**********
Bill
***********/

public class EnterpriseBillRequest {
    
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var billId: String? = nil
    
    public convenience init?() {
        self.init(billId: nil)
    }
    
    public init?(billId: String?)
    {
        self.billId = billId
        let requestString = buildRequestUrl()
        buildRequest(requestString)
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)/enterprise/bills"
        if (billId != nil) {
            self.getsArray = false
            requestString += "/\(billId!)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request!.HTTPMethod = HTTPType.GET.rawValue
        
        self.request!.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request!
    }
    //Sending the request
    
    public func send(completion: ((BillResult) -> Void)?) {
        
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

/**********
Customer
***********/

public class EnterpriseCustomerRequest {
    
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var customerId: String?
    
    public convenience init?() {
        self.init(customerId: nil)
    }
    
    public init?(customerId: String?)
    {
        self.customerId = customerId
        let requestString = buildRequestUrl()
        buildRequest(requestString)
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)/enterprise/customers"
        if (customerId != nil) {
            self.getsArray = false
            requestString += "/\(customerId!)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request!.HTTPMethod = HTTPType.GET.rawValue
        
        self.request!.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request!
    }
    //Sending the request
    
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

/**********
Account
***********/

public class EnterpriseAccountRequest {
    
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var accountId: String?
    
    public convenience init?() {
        self.init(accountId: nil)
    }
    
    public init?(accountId: String?)
    {
        self.accountId = accountId
        let requestString = buildRequestUrl()
        buildRequest(requestString)
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)/enterprise/accounts"
        if (accountId != nil) {
            self.getsArray = false
            requestString += "/\(accountId!)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request!.HTTPMethod = HTTPType.GET.rawValue
        
        self.request!.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request!
    }
    //Sending the request
    
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

/**********
Merchant
***********/

public class EnterpriseMerchantRequest {
    
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var merchantId: String?
    
    public convenience init?() {
        self.init(merchantId: nil)
    }
    
    public init?(merchantId: String?)
    {
        self.merchantId = merchantId
        let requestString = buildRequestUrl()
        buildRequest(requestString)
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)/enterprise/merchants"
        if (merchantId != nil) {
            self.getsArray = false
            requestString += "/\(merchantId!)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request!.HTTPMethod = HTTPType.GET.rawValue
        
        self.request!.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request!
    }
    //Sending the request
    
    public func send(completion: ((MerchantResult) -> Void)?) {
        
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