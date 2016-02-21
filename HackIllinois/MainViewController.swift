//
//  ViewController.swift
//  HackIllinois
//
//  Created by Itua Ijagbone on 2/20/16.
//  Copyright © 2016 HackIllinois. All rights reserved.
//

import UIKit
import CZPicker

class MainViewController: UIViewController {

    @IBOutlet var machineSearchLabel: UILabel!
    @IBOutlet var dropOffMarker: UIImageView!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var etaLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var etaCostView: UIView!
    @IBOutlet var dropoffLabel: UILabel!
    @IBOutlet var etacostView: UIView!
    
    @IBOutlet var requestButton: UIButton!
    @IBOutlet var dropoffMarkerContraint: NSLayoutConstraint!
    
    let locationManager = CLLocationManager()
    let serviceProvider = MachineServiceProvider()
    let machineTypes = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchGesture = UITapGestureRecognizer(target: self, action: "openMachineDropDown")
        machineSearchLabel.userInteractionEnabled = true
        machineSearchLabel.addGestureRecognizer(searchGesture)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openMachineDropDown() {
        let picker = CZPickerView(headerTitle: "Select Machine Type", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = true
        picker.show()
    }
    
    @IBAction func makeRequest(sender: AnyObject) {
    
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geoCoder = GMSGeocoder()
        
        geoCoder.reverseGeocodeCoordinate(coordinate) { response, error in
            self.dropoffLabel.unlock()
            if let address = response?.firstResult() {
                let lines = address.lines as! [String]
                self.dropoffLabel.text = lines.joinWithSeparator("\n")
                let labelHeight:CGFloat = 50.0 + 50.0 + 40.0 + 20.0
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
                UIView.animateWithDuration(0.25) {
                    self.dropoffMarkerContraint.constant = ((labelHeight - self.topLayoutGuide.length) * 0.5)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func fetchMachinesNearBy(coordinate: CLLocationCoordinate2D, machineType: String) {
        mapView.clear()
        serviceProvider.fetchMachinesNearBy(coordinate, type: machineType) { machines in
            for machine: Machine in machines {
                let marker = MachineMarker(machine: machine)
                marker.map = self.mapView
            }
        }
    }
    
    func calculateETA(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) {
        serviceProvider.getDirectionWithDistance(coordinate1, to: coordinate2) { googleDirections in
            self.etaLabel.text = googleDirections.duration
            let cost:Float = Float(googleDirections.distance)! * 0.2
            self.costLabel.text = "$\(cost)"
        }
    }

}

extension MainViewController:CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
            if !machineSearchLabel.text!.isEmpty {
                fetchMachinesNearBy(location.coordinate, machineType: machineSearchLabel.text!)
            }
        }
    }
}

extension MainViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        self.dropoffLabel.lock()
    }
    
    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
        let machineMaker = marker as! MachineMarker
        calculateETA(machineMaker.machine.coordinate, coordinate2: mapView.camera.target)
        return nil
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        mapView.selectedMarker = nil
        return false
    }
}

extension MainViewController:CZPickerViewDelegate {
    
}

extension MainViewController:CZPickerViewDataSource {
    func numberOfRowsInPickerView(pickerView: CZPickerView!) -> Int {
        return machineTypes.count
    }
    
    func czpickerView(pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return "option \(row)";
    }
    
    func czpickerView(pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        //fetchMachinesNearBy(self.mapView.camera.target, machineType: machineTypes[row])
        print(machineTypes[row])
    }
}
