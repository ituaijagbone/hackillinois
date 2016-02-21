//
//  Machine.swift
//  HackIllinois
//
//  Created by Itua Ijagbone on 2/20/16.
//  Copyright © 2016 HackIllinois. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON

class Machine {
    let name: String
    var coordinate: CLLocationCoordinate2D
    let machineType: String
    
    init(dictionary:[String : AnyObject]) {
        let json = JSON(dictionary)
        name = json["name"].stringValue
        machineType = json["machineType"].stringValue
        let lat = json["lat"].doubleValue as CLLocationDegrees
        let lng = json["lng"].doubleValue as CLLocationDegrees
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    
    
}