//
//  BNCBunch.swift
//  Bunch
//
//  Created by David Woodruff on 2015-09-19.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation
import Parse

enum BNCRelation {
    case Host
    case Viewer
    case Attendee
    case Creator
}

func ==(lhs: BNCBunch, rhs: BNCBunch) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class BNCBunch: Hashable {
    
    var PFBunch: PFObject
    var online: Bool
    //var viewed: Bool = false
    var manager: BNCManager
    
    var hashValue: Int {
        get {
            return PFBunch.hashValue
        }
    }
    
    init(bunch: PFObject, manager: BNCManager) {
        PFBunch = bunch
        self.manager = manager
        self.online = true
    }
    
    init(manager: BNCManager) {
        PFBunch = PFObject(className: GetUniversity().parseDBName())
        self.manager = manager
        self.online = false
        self.creator = PFUser.currentUser()!
    }
    
    var time: NSDate? {
        get {
            if let val = PFBunch["time"] as? NSDate {
                return val
            } else { return nil }
        }
        set {
            PFBunch["time"] = newValue
        }
    }
    
    var creator: PFUser? {
        get {
            if let val = PFBunch["creator"] as? PFUser {
                return val
            } else { return nil }
        }
        set {
            guard !online else { return }
            PFBunch["creator"] = newValue
        }
    }
    
    var checkedIn: [PFUser]? {
        get {
            if let val = PFBunch["checkedIn"] as? [PFUser] {
                return val
            } else { return nil }
        }
    }
    
    var type: String? {
        get {
            if let val = PFBunch["type"] as? String {
                return val
            } else { return nil }
        }
        set {
            PFBunch["type"] = newValue
        }
    }
    
    var blurb: String? {
        get {
            if let val = PFBunch["blurb"] as? String {
                return val
            } else { return nil }
        }
        set {
            PFBunch["blurb"] = newValue
        }
    }
    
    var coordinate: CLLocationCoordinate2D? {
        get {
            if let val = PFBunch["coordinate"] as? PFGeoPoint {
                return CLLocationCoordinate2DMake(val.latitude, val.longitude)
            } else { return nil }
        }
        set {
            let point = PFGeoPoint(latitude:newValue!.latitude, longitude:newValue!.longitude)
            PFBunch["coordinate"] = point
        }
    }
    
    var size: Int? {
        get {
            if let val = PFBunch["size"] as? Int {
                return val
            } else { return nil }
        }
        set {
            PFBunch["size"] = newValue
        }
    }
    
    var photo: UIImage? {
        get {
            if let val = PFBunch["photo"] as? PFFile {
                do {
                    let imageData = try val.getData()
                    return UIImage(data: imageData)
                } catch {
                    print(error)
                    return nil
                }
                
            }
            else { return nil }
        }
        set {
            let imageData = newValue!.lowestQualityJPEGNSData
            let imageFile = PFFile(name:"bunchPhoto", data:imageData)
            PFBunch["photo"] = imageFile
        }
    }
    
    var icon: String? {
        get {
            if let val = PFBunch["icon"] as? String {
                return val
            } else { return nil }
        }
        set {
            if newValue != nil {
                PFBunch["icon"] = newValue
                manager.mapView.updateAnnotationForBunch(self)
            }
        }
    }
    
    var reported: Bool? {
        get {
            if let val = PFBunch["reported"] as? [PFUser] {
                for i in val {
                    if i == PFUser.currentUser() {
                        return true
                    }
                }
                return false
            } else {
                return nil
            }
        }
    }
    
    //
    //  Local variables
    //
    
    
    var relation: BNCRelation {
        get {
            if online == false { return .Creator }
            else if PFUser.currentUser() == self.creator { return .Host }
            else if checkedIn!.contains(PFUser.currentUser()!) { return .Attendee }
            else { return .Viewer }
        }
    }
    
    //
    //  Handy Functions
    //
    
    func checkIn() {
        if relation == .Viewer {
            manager.attendance.validateBunchForCheckIn(self)
        }
    }
    
    func checkOut() {
        PFDelegate().checkOutOfBunch(self)
    }
    
    func renew() {
        if type == "present" {
            PFDelegate().renewBunch(self)
        }
    }
    
    func report() {
        PFDelegate().reportBunch(self)
    }
    
    func create() {
        if relation == .Creator {
            PFDelegate().createBunch(self)
        }
    }
    
    func finish() {
        PFDelegate().finishBunch(self)
    }
    
    func save() {
        PFDelegate().saveBunch(self)
    }
    
    func fetch() {
        PFDelegate().fetchBunch(self)
    }
    
    func success(action: PFDelegateAction) {
        switch action {
        case .CheckIn:
            manager.activeBunch = self
        case .CheckOut:
            manager.activeBunch = nil
        case .Renew:
            ()
        case .Create:
            online = true
            manager.activeBunch = self
        case .Finish:
            manager.endActiveBunchRelationship(false)

        default: break
        }
        if ![.Fetch, .Finish, .Create, .CheckOut].contains(action) { fetch() }
        let bvc = manager.homeVC.bunchVC
        if bvc != nil {
            bvc!.finishActionWithSuccess(action, success: true)
        }
    }
    
    func failure(action: PFDelegateAction) {
        var message: String?
        switch action {
        case .CheckIn:
            message = "We couldn't check you in. Try again?"
        case .CheckOut:
            message = "We couldn't check you out. Try again?"
        case .Renew:
            message = "That renew out didn't work. Try again?"
        case .Create:
            message = "The bunch didn't get created. Try again?"
        case .Finish:
            message = "We couldn't finish the bunch for you. Try again?"
        case .Report:
            message = "The bunch didn't get reported. Try again?"
        case .Save:
            message = "We were unable to save the bunch. Try again?"
        case .Fetch:
            message = nil
        default: message = nil
        }
        let bvc = manager.homeVC.bunchVC
        if bvc != nil { bvc!.finishActionWithSuccess(action, success: false) }
        if message != nil {
            manager.error.showErrorWithMessageOnBunchVC(message!)
        }
    }
    
    func askForPushPermissionIfNeeded() {
        if !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
            let defaults = NSUserDefaults.standardUserDefaults()
            let pushAsked = defaults.boolForKey("pushAlertAsked") as Bool?
            if pushAsked == nil || pushAsked == false {
                let alert = UIAlertController(title: "Notifications", message: "We'd like to send you a buzz when someone checks in to your bunch", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                    defaults.setBool(true, forKey: "pushAlertAsked")
                    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
                    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                    UIApplication.sharedApplication().registerForRemoteNotifications()
                }))
                manager.homeVC.presentViewController(alert, animated: true, completion: nil)
            }
        }

    }
}