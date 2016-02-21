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
        let currentDate = NSDate()
        dateFormatter.dateFormat = "yyyy-02-dd"

        let urlString = "http://api.reimaginebanking.com/accounts/\(creditCard)"
        Alamofire.request(.POST, urlString, parameters: ["key":key, "status": "pending",
            "payee": "Agrimeant", "nickname": reason, "payment_date": dateFormatter.stringFromDate(currentDate), "recurring_date": 1, "payment_amount": amount]).responseJSON { response in
            
            var status = false
            let json = JSON(response.result.value!)
            if Int(json["code"].stringValue) == 201 {
                status = true
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(status)
            }
         }
    }
}