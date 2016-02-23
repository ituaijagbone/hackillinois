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
    
    @IBOutlet var navigationItem1: UINavigationItem!
    
    var cost:Float = 0
    let locationManager = CLLocationManager()
    let serviceProvider = MachineServiceProvider()
    let machineTypes = ["Cane Harvester", "Combine", "Cotton Picker", "Cotton Stripper", "Forage Harvester", "Other", "Pickup Truck", "Sprayer", "Tractor", "Utility Vechicle", "Windrower"]
    var machineType = ""
    var isMarkerSelected = false
    var from:CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchGesture = UITapGestureRecognizer(target: self, action: "openMachineDropDown")
        machineSearchLabel.userInteractionEnabled = true
        machineSearchLabel.addGestureRecognizer(searchGesture)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        navigationItem1.rightBarButtonItems?.removeAtIndex(0)
        
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
        picker.headerBackgroundColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1.0)
        picker.confirmButtonBackgroundColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1.0)
        picker.show()
    }
    
    @IBAction func clearAndDisappear(sender: AnyObject) {
        clear()
        navigationItem1.rightBarButtonItems?.removeAtIndex(0)
    }
    
    func clear() {
        machineType = ""
        isMarkerSelected = false
        from = nil
        
        machineSearchLabel.text = "Select Machine Type"
        dropoffLabel.text = ""
        etaLabel.text = "0 min"
        costLabel.text = "$0"
    }
    
    @IBAction func makeRequest(sender: AnyObject) {
        if !machineType.isEmpty && from != nil {
            performSegueWithIdentifier("payBillIdentifier", sender: sender)
        } else {
            showPrompt("Can't make drop off request")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "payBillIdentifier" {
            let captialOneVC = segue.destinationViewController as! CapitalOneViewController
            captialOneVC.price = cost
            captialOneVC.eta = etaLabel.text!
            captialOneVC.machineName = machineType
            
            clear()
        }
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geoCoder = GMSGeocoder()
        
        geoCoder.reverseGeocodeCoordinate(coordinate) { response, error in
            self.dropoffLabel.unlock()
            if let address = response?.firstResult() {
                let lines = address.lines as! [String]
                self.dropoffLabel.text = lines.joinWithSeparator("\n")
                var labelHeight:CGFloat = 50.0 + 50.0 + 40.0 + 20.0
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
                if !self.machineType.isEmpty {
                    self.fetchMachinesNearBy(self.mapView.camera.target, machineType: self.machineType)
                }
                UIView.animateWithDuration(0.25) {
                    labelHeight = labelHeight - 20 - 40
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
            
            if self.isMarkerSelected {
                if self.from != nil {
                    self.etaLabel.lock()
                    self.costLabel.lock()
                    self.calculateETA(self.from, coordinate2: self.mapView.camera.target)
                }
            }
            
            if self.navigationItem1.rightBarButtonItems?.count < 1 {
                let item = UIBarButtonItem(title: "Clear", style: .Plain, target: self, action: "clearAndDisappear:")
                self.navigationItem1.rightBarButtonItems?.append(item)
            }
         }
    }
    
    func calculateETA(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) {
        serviceProvider.getDirectionWithDistance(coordinate1, to: coordinate2) { googleDirections in
            self.etaLabel.unlock()
            self.costLabel.unlock()
            self.etaLabel.text = googleDirections.duration
            let cost:Float = Float(googleDirections.distance)! * 0.2
            self.costLabel.text = "$\(cost)"
            self.cost = cost
            self.mapView.selectedMarker = nil
        }
    }
    
    func showPrompt(message: String) {
        let actionAlert = UIAlertController(title: "Alert", message: message, preferredStyle: .Alert)
        let dismissHandler = {
            (action: UIAlertAction!) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        actionAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: dismissHandler))
        presentViewController(actionAlert, animated: true, completion: nil)
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
            
        }
    }
}

extension MainViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        self.dropoffLabel.lock()
        if (gesture) {
            dropOffMarker.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
    
//    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
//        let machineMaker = marker as! MachineMarker
//        etaLabel.lock()
//        costLabel.lock()
//        from = machineMaker.machine.coordinate
//        calculateETA(machineMaker.machine.coordinate, coordinate2: mapView.camera.target)
//        isMarkerSelected = true
//        return nil
//    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        dropOffMarker.fadeIn(0.25)
        mapView.selectedMarker = nil   
        isMarkerSelected = false
        return false
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
//        dropOffMarker.fadeOut(0.25)
        let machineMaker = marker as! MachineMarker
        etaLabel.lock()
        costLabel.lock()
        from = machineMaker.machine.coordinate
        calculateETA(machineMaker.machine.coordinate, coordinate2: mapView.camera.target)
        isMarkerSelected = true
        return true
    }
}

extension MainViewController:CZPickerViewDelegate {
    func czpickerView(pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        machineType = machineTypes[row]
        self.machineSearchLabel.text = machineType
        fetchMachinesNearBy(self.mapView.camera.target, machineType: machineType)
    }
    
    func czpickerViewDidClickCancelButton(pickerView: CZPickerView!) {
//        machineType = ""
    }
}

extension MainViewController:CZPickerViewDataSource {
    func numberOfRowsInPickerView(pickerView: CZPickerView!) -> Int {
        return machineTypes.count
    }
    
    func czpickerView(pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return machineTypes[row];
    }
}

