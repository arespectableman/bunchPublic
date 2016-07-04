//
//  SettingsTabViewController.swift
//  Bunch
//
//  Created by David Woodruff on 2015-08-31.
//  Copyright (c) 2015 Jukeboy. All rights reserved.
//

import UIKit
import Parse

class FinishTabViewController: UIViewController, Refreshable {

    @IBOutlet weak var visibilityLabel: UILabel!
    
    @IBOutlet weak var disbandButton: UIButton!
    
    @IBAction func disbandAction(sender: AnyObject) {
        //delete bunch, remove it from map if user approves
        var alertView = UIAlertController()
        alertView = UIAlertController(title: "All done?", message: "This will delete the bunch", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        alertView.addAction(UIAlertAction(title: "Finish", style: .Destructive, handler: { (alertAction) -> Void in
            self.bunch.finish()
        }))

        presentViewController(alertView, animated: true, completion: nil)
    }
    
    var bunch: BNCBunch!
    
    var parent: BunchTabBarController!
    
    override func viewDidAppear(animated: Bool) {
        bunch = parent.bunch
        if bunch != nil {
            if self.isViewLoaded() {
                refresh()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func refresh() {
        let bunchTime = bunch.time!
        let dateformmatter:NSDateFormatter = NSDateFormatter()
        dateformmatter.dateFormat = "h:mm a"
        
        if bunch.type == "present" {
            let hideTime = NSCalendar.currentCalendar().dateByAddingUnit(
                .Minute,
                value: 90,
                toDate: bunchTime,
                options: NSCalendarOptions(rawValue: 0))
            visibilityLabel.text = "This bunch will automatically finish at \(dateformmatter.stringFromDate(hideTime!)) unless renewed."
        } else {
            visibilityLabel.text = "This bunch will automatically finish half an hour after it starts"
        }
    
    }

}
