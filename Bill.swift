//
//  Bill.swift
//  HackIllinois
//
//  Created by Itua Ijagbone on 2/21/16.
//  Copyright © 2016 HackIllinois. All rights reserved.
//

import Foundation

import UIKit
import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON

class CaptitalOneServiceProvider {
    let key = "d551de08fcc5931bf5fb02d27b3f9ec3"
    let customerID = "56c66be5a73e492741507334"
    let creditCard = "56c66be6a73e492741507cfd"
    func payBill(amount: Float, reason: String, completion:((Bool) -> Void)) -> () {
        let dateFormatter = NSDateFormatter()
        _ = NSDate()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        
        let urlString = "http://api.reimaginebanking.com/accounts/56c66be6a73e492741507cfd/purchases?key=d551de08fcc5931bf5fb02d27b3f9ec3"
        
        let params:Dictionary<String, AnyObject> = [
            "merchant_id": "string",
            "medium": "balance",
            "purchase_date": "2016-02-21",
            "amount": 0,
            "status": "pending",
            "description": "string"
        ]
        
        let myUrl = NSURL(string: urlString);
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        // Compose a query string
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted);
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {  data, response, error in
            if error != nil
            {
                print("error=\(error)")
                dispatch_async(dispatch_get_main_queue()) {
                    completion(false)
                    return
                }
            }
            
            // You can print out response object
            print("response = \(response)")
            
            // Print out response body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            //Let’s convert response sent from a server side script to a NSDictionary object:
            
            let myJSON = try! NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
            if let parseJSON = myJSON {
                // Now we can access value of First Name by its key
                let firstNameValue = parseJSON["code"] as? Int
                print("code: \(firstNameValue)")
                if firstNameValue! == 201 {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(true)
                        
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(false)
                    }
                }
            }
        }
        
        task.resume()
    }
}