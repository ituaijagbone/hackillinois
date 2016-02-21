//
//  MachineServiceProvider.swift
//  HackIllinois
//
//  Created by Itua Ijagbone on 2/20/16.
//  Copyright © 2016 HackIllinois. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON

struct GoogleDirections {
    var duration:String
    var distance:String
}

class MachineServiceProvider {
    func fetchMachinesNearBy(coordinate: CLLocationCoordinate2D, type: String, completion: (([Machine]) -> Void)) ->() {
        let urlString = "http://52.90.109.150:2000/machines"
        print(urlString)
        Alamofire.request(.GET, urlString, parameters: ["lat":coordinate.latitude, "lng":coordinate
            .longitude, "machine_type":type]).responseJSON { response in
            var machineArray = [Machine]()
            print(response.result.value)
            if let value = response.result.value {
                let json = JSON(value)
                if let results = json["results"].arrayObject as? [[String:AnyObject]] {
                    print(results)
                    for rawMachine in results {
                        let machine = Machine(dictionary: rawMachine)
                        machineArray.append(machine)
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(machineArray)
            }
        }
    }
    
    func getDirectionWithDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: ((GoogleDirections) -> Void)) -> () {
        let urlString = "http://52.90.109.150:2000/eta"
        Alamofire.request(.GET, urlString, parameters: ["origin":"\(from.latitude),\(from.longitude)", "destination":"\(to.latitude),\(to.longitude)"]).responseJSON { response in
            var googleDirections = GoogleDirections(duration: "", distance: "")
            if let value = response.result.value {
                let json = JSON(value)
                print(json)
                if let result = json["results"].arrayObject as? [[String:AnyObject]] {
                    let dict = result[0]
                    print(dict)
                    googleDirections.duration = dict["duration"] as! String
                    googleDirections.distance = String(dict["distance"] as! Int)
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(googleDirections)
            }
        }
    }
}
