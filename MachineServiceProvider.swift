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
        let urlString = "/lat/\(coordinate.latitude)/lng/\(coordinate.longitude)"
        Alamofire.request(.GET, urlString).responseJSON { response in
            var machineArray = [Machine]()
            if let value = response.result.value {
                let json = JSON(value)
                if let results = json["results"].arrayObject as? [[String:AnyObject]] {
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
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&mode=driving&traffic_model=best_guess&departure_time=now&key=AIzaSyBxDTa-M-OZ80RJ92qrnLHlIbNRAVweJi8"
        Alamofire.request(.GET, urlString).responseJSON { response in
            var googleDirections = GoogleDirections(duration: "", distance: "")
            if let value = response.result.value {
                let json = JSON(value)
                if let duration = json["routes"][0]["legs"][0]["duration"]["text"].string {
                    googleDirections.duration = duration
                }
                if let distance = json["routes"][0]["legs"][0]["distance"]["value"].string {
                    googleDirections.distance = distance
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(googleDirections)
            }
        }
    }
}
