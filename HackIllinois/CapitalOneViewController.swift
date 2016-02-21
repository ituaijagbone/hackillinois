//
//  CapitalOneViewController.swift
//  HackIllinois
//
//  Created by Itua Ijagbone on 2/21/16.
//  Copyright © 2016 HackIllinois. All rights reserved.
//

import UIKit

class CapitalOneViewController: UIViewController {
    var price: Float!
    var eta: String!
    var machineName: String!
    let billProvider = CaptitalOneServiceProvider()
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var machineNameLabel: UILabel!
    @IBOutlet var spinnerView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        costLabel.text = String(price)
        machineNameLabel.text = machineName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pay(sender: AnyObject) {
        spinnerView.startAnimating()
        billProvider.payBill(price, reason: "Renting of " + machineName) { completion in
            self.spinnerView.stopAnimating()
            if completion {
                self.showPrompt("Transaction Successful")
            } else {
                self.showPrompt("Transaction Failed")
            }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
