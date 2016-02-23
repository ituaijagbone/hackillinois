//
//  MachineMarker.swift
//  HackIllinois
//
//  Created by Itua Ijagbone on 2/20/16.
//  Copyright © 2016 HackIllinois. All rights reserved.
//

import UIKit
class MachineMarker: GMSMarker {
    let machine: Machine
    
    init(machine: Machine) {
        self.machine = machine
        super.init()
        position = machine.coordinate
        icon = UIImage(named: "trackor")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = kGMSMarkerAnimationPop
    }
}