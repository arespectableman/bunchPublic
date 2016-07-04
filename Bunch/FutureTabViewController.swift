//
//  FutureTabViewController.swift
//  Bunch
//
//  Created by David Woodruff on 2015-09-01.
//  Copyright (c) 2015 Jukeboy. All rights reserved.
//

import UIKit
import Parse

class FutureTabViewController: UIViewController, Refreshable {
    
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var checkedInLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var blurbTextView: UITextView!
    @IBOutlet weak var blurbTextHeightConstraint: NSLayoutConstraint!
    
    @IBAction func imageBlurbAction(sender: AnyObject) {
        if imageView.image != nil {
            performSegueWithIdentifier(Segue.TabToImageDetail, sender: self)
        }
    }
    
    let gradientLayer = CAGradientLayer()
    
    var dateFormatter: NSDateFormatter!
    
    var bunch: BNCBunch!

    override func viewDidAppear(animated: Bool) {
        refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gradient
        gradientView.frame = self.view.frame
        gradientLayer.frame = self.gradientView.frame
        let topColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).CGColor as CGColorRef
        let bottomColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7).CGColor as CGColorRef
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
        
        //bunch creator
        bunch.creator!.fetchInBackgroundWithBlock {
            (creator, error) -> Void in
            if creator != nil {
                let creatorName = creator!.objectForKey("name") as! String
                self.hostLabel.text = "Created by \(creatorName)"
            }
        }
        
        //bunch time
        let time = bunch.time!
        dateFormatter = NSDateFormatter()
        
        if NSCalendar.currentCalendar().isDateInToday(time) {
            dateFormatter.dateFormat = "h:mm a"
            timeLabel.text = "Today, \(dateFormatter.stringFromDate(time))"
        } else if NSCalendar.currentCalendar().isDateInTomorrow(time) {
            dateFormatter.dateFormat = "h:mm a"
            timeLabel.text = "Tomorrow, \(dateFormatter.stringFromDate(time))"
        } else {
            dateFormatter.dateFormat = "EEE, h:mm a"
            timeLabel.text = dateFormatter.stringFromDate(time)
            
        }
        getDataFromParse()
    }
    
    func refresh() {
        getDataFromParse()
    }
    
    func temporaryPlusOne() { //because Parse is just a tad slow
        checkedInLabel.text = "\(bunch.checkedIn!.count+1) checked-in"
    }
    
    func getDataFromParse() {
        
        //bunch blurb
        blurbTextView.text = bunch.blurb!
        
        //checkedin number
        if bunch.size == 0 {
            checkedInLabel.text = "\(bunch.checkedIn!.count) checked-in"
        } else {
            checkedInLabel.text = "\(bunch.checkedIn!.count)/\(bunch.size!) checked-in"
        }
        
        //bunch photo
        let qos = QOS_CLASS_BACKGROUND
        let queue = dispatch_get_global_queue(qos, 0)
        dispatch_async(queue) {
            let img = self.bunch.photo
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView.image = img
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nc = segue.destinationViewController as? UINavigationController {
            if let dvc = nc.topViewController as? ImageDetailViewController {
                dvc.image = imageView.image
            }
        }
    }
}
