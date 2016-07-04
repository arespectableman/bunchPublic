////
////  BunchBrain.swift
////  Bunch
////
////  Created by David Woodruff on 2015-09-08.
////  Copyright (c) 2015 Jukeboy. All rights reserved.
////
//
//import Foundation
//import Parse
//
//
//class BNCBrain {
//    
//    var joinedBunch: BNCBunch! {
//        willSet {
//            if newValue != nil && joinedBunch != nil {
//                do {
//                    try joinedBunch.PFbunch.unpin()
//                        print("joinedBunch unpinned")
//                    } catch {
//                        print(error)
//                }
//            }
//        }
//        didSet {
//            if joinedBunch != nil {
//                joinedBunch.PFbunch.pinInBackgroundWithBlock{
//                    (success: Bool, error: NSError?) -> Void in
//                    if (success) {
//                        print("joinedBunch pinned")
//                    } else {
//                        self.mapVC.reportErrorWithMessage("Something went wrong retrieving details. Please connect to the internet and try again.")
//                        print(error)
//                    }
//                }
//            }
//        }
//    }
//    
////    var viewedBunch: BNCBunch? {
////        get {
////            if homeVC.tabBar.bunch == nil {
////                return nil
////            }
////            return homeVC.tabBar.bunch
////        }
////    }
//    
//    var tabInformation = [AnyObject?]()
//    
//    var user: PFUser
//    
//    var homeVC: HomeViewController
//    
//    var existingBunchSearchCompleted: Bool = false
//    
//    var onboarded: Bool {
//        get {
//            return user["onboarded"] as! Bool
//        }
//    }
//    
//    init(homeVC: HomeViewController) {
//        self.homeVC = homeVC
//        self.user = PFUser.currentUser()!
//        _checkForBunch()
//    }
//    
//    func createBunch(bunch: BNCBunch) {
//        
//        if !existingBunchSearchCompleted {
//            loadJoinedBunch()
//            self.mapVC.reportErrorWithMessage("Error loading profile, please try again")
//            self.mapVC.stopActivityIndicator()
//            return
//        }
//        
//        if !tabInformation.isEmpty {
//            switch bunch.type! {
//            case "present":
//                if tabInformation[1] != nil {
//                    bunch.photo = (tabInformation[1] as! UIImage)
//                }
//                bunch.PFbunch["size"] = 0
//                bunch.time = NSDate()
//                case "future":
//                bunch.time = (tabInformation[1] as! NSDate)
//                if tabInformation[2] != nil {
//                    bunch.photo = (tabInformation[2] as! UIImage)
//                }
//                bunch.PFbunch["size"] = 0
//            default: break
//            }
//            
//            bunch.blurb = (tabInformation[0] as! String)
//            bunch.hidden = false
//            
//            bunch.PFbunch["creator"] = user
//            bunch.PFbunch["checkedIn"] = [user]
//            bunch.PFbunch["checkIns"] = 0
//            bunch.PFbunch["reported"] = []
//            
//            bunch.PFbunch.saveInBackgroundWithBlock {
//                (success: Bool, error: NSError?) -> Void in
//                self.mapVC.stopActivityIndicator()
//                if (success) {
//                    print("bunch created")
//                    self.joinedBunch = bunch
//                    self.mapVC.dismissViewedBunchWithInteraction(true)
//                    
//                    if !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
//                        let defaults = NSUserDefaults.standardUserDefaults()
//                        let pushAsked = defaults.boolForKey("pushAlertAsked") as Bool?
//                        if pushAsked == nil || pushAsked == false {
//                            let alert = UIAlertController(title: "Notifications", message: "We'd like to send you a buzz when someone checks in to your bunch", preferredStyle: .Alert)
//                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
//                                let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
//                                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
//                                UIApplication.sharedApplication().registerForRemoteNotifications()
//                            }))
//                            self.mapVC.presentViewController(alert, animated: true, completion: nil)
//                            defaults.setBool(true, forKey: "pushAlertAsked")
//                        }
//                    }
//                    
//                } else {
//                    self.mapVC.dismissViewedBunchWithInteraction(false)
//                    self.mapVC.reportErrorWithMessage("Something went terribly wrong creating the bunch. Please try again")
//                    print(error)
//                }
//            }
//        } else {
//            self.mapVC.stopActivityIndicator()
//            self.mapVC.reportErrorWithMessage("Something went terribly wrong creating the bunch. Please try again")
//        }
//    }
//    
//    func _checkForBunch() {
//        let query = PFQuery(className: "Bunch")
//        query.whereKey("checkedIn", equalTo: PFUser.currentUser()!)
//        query.findObjectsInBackgroundWithBlock {
//            (objects, error) -> Void in
//            if (error != nil || objects!.isEmpty) {
//                if error != nil {
//                    self.mapVC.reportErrorWithMessage("Please connect to the internet and try again")
//                    print(error) }
//                else { print("no bunch found"); self.existingBunchSearchCompleted = true }
//            } else {
//                if let bunches = objects as [PFObject]! {
//                    let bunch = BNCBunch(bunch: bunches[0])
//                    self.existingBunchSearchCompleted = true
//                    self.joinedBunch = bunch
//                    self.mapVC.handleJoinedBunchUI()
//                    for i in 0...bunches.count-1 {
//                        if bunches.count == 1 { return }
//                        //remove them and maybe delete
//                        if let bunchKids = bunches[i]["checkedIn"] as? [PFUser] {
//                            if bunchKids[0] == self.user {
//                                do {
//                                    try bunches[i].delete()
//                                } catch {
//                                    print(error)
//                                }
//                            } else {
//                                bunches[i].removeObject(self.user, forKey: "checkedIn")
//                                do {
//                                    try bunches[i].save()
//                                } catch {
//                                    print(error)
//                                }
//                            }
//                        }
//                        self.mapVC.reportErrorWithMessage("We detected multiple bunches to your account and have deleted or removed you from them")
//                    }
//                }
//            }
//        }
//    }
//    
//    func checkIn(bunch: BNCBunch) {
//        
//        if !existingBunchSearchCompleted {
//            _checkForBunch()
//            self.mapVC.reportErrorWithMessage("Error loading profile, please try again.")
//            self.mapVC.stopActivityIndicator()
//            return
//        }
//        do {
//            try bunch.PFbunch.fetch()
//        } catch {
//            print(error)
//        }
//        if bunch.hidden! || !bunchValid(bunch) {
//            self.mapVC.dismissViewedBunchWithInteraction(false)
//            self.mapVC.reportErrorWithMessage("This bunch is no longer availble")
//            self.mapVC.stopActivityIndicator()
//            return
//        }
//        
//        PFCloud.callFunctionInBackground("checkIn", withParameters: ["bunchId":(bunch.PFbunch.objectId)!]) {
//            (response: AnyObject?, error: NSError?) -> Void in
//            self.mapVC.stopActivityIndicator()
//            let responseString = response as? String
//            if responseString == "true" {
//                self.joinedBunch = bunch
//                do {
//                    try self.joinedBunch.PFbunch.fetch()
//                } catch {
//                    print(error)
//                }
//                self.mapVC.determineUtilityButton()
//                self.mapVC.tabBar.updateToCheckedIn()
//                self.mapVC.refresh()
//                
//            } else {
//                self.mapVC.reportErrorWithMessage("We were unable to check in, the bunch may no longer be available")
//            }
//        }
//    }
//    
//    func renew() {
//        if joinedBunch != nil {
//            joinedBunch.time = NSDate()
//            joinedBunch.PFbunch.saveInBackgroundWithBlock {
//                (success: Bool, error: NSError?) -> Void in
//                self.mapVC.stopActivityIndicator()
//                if (success) {
//                    print("successfully renewed bunch")
//                } else {
//                    self.mapVC.reportErrorWithMessage("Something when wrong with the renew attempt, pleaase try again!")
//                    print(error)
//                }
//            }
//        } else {
//            self.mapVC.stopActivityIndicator()
//        }
//    }
//    
//    func checkOut() -> Bool {
//        joinedBunch.PFbunch.removeObject(PFUser.currentUser()!, forKey: "checkedIn")
//        let error = NSErrorPointer()
//        do {
//            try joinedBunch.PFbunch.save()
//        } catch {
//            print(error)
//        }
//        self.mapVC.stopActivityIndicator()
//        SwiftOverlays.removeAllBlockingOverlays()
//        if error == nil {
//            print("successfully left bunch")
//            joinedBunch = nil
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func bunchValid(bunch: BNCBunch) -> Bool { //runs on the main thread
//        let query = PFQuery(className: "Bunch")
//        query.whereKey("objectId", equalTo: bunch.PFbunch.objectId!)
//        let error = NSErrorPointer()
//        do {
//            try query.getFirstObject()
//        } catch {
//            print(error)
//        }
//        if error == nil {
//            print("bunch valid")
//            return true
//        } else {
//            print("bunch invalid")
//            return false
//        }
//    }
//    
//    func bunchValidInBackground(bunch: BNCBunch) {
//        let query = PFQuery(className: "Bunch")
//        if bunch.PFbunch.objectId == nil { return } //viewed bunch can't be valid
//        query.whereKey("objectId", equalTo: bunch.PFbunch.objectId!)
//        query.getFirstObjectInBackgroundWithBlock{
//            (object: PFObject?, error: NSError?) -> Void in
//            if error != nil { //there is error
//                self.mapVC.mapView.removeBunchFromMap(bunch)
//                self.mapVC.dismissViewedBunchWithInteraction(false)
//                self.mapVC.reportErrorWithMessage("That bunch is no longer available")
//                self.mapVC.refresh()
//                print(error)
//            } else {
//                if bunch.hidden! {
//                    if self.joinedBunch != nil {
//                        if bunch.PFbunch == self.joinedBunch.PFbunch {
//                            print("Requested bunch is valid")
//                            return
//                        }
//                    }
//                    self.mapVC.mapView.removeBunchFromMap(bunch)
//                    self.mapVC.dismissViewedBunchWithInteraction(false)
//                    self.mapVC.reportErrorWithMessage("That bunch is no longer available")
//                    self.mapVC.refresh()
//                }
//            }
//        }
//    }
//    
//    func joinedBunchValid() {
//        let query = PFQuery(className: "Bunch")
//        query.whereKey("objectId", equalTo: joinedBunch.PFbunch.objectId!)
//        query.getFirstObjectInBackgroundWithBlock{
//            (object: PFObject?, error: NSError?) -> Void in
//            if error != nil {
//                self.mapVC.reportErrorWithMessage("The bunch you were checked into is no longer available")
//                self.joinedBunch = nil
//                self.mapVC.refresh()
//                print(error)
//            } else {
//                print("Joined bunch valid")
//            }
//        }
//    }
//}
//
//
