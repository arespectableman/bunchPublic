//
//  BNCAttendance.swift
//  Bunch
//
//  Created by David Woodruff on 2015-11-05.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation
import Parse

protocol BNCAttendanceDelegate {
    
}

class BNCAttendance {
    
    let user: PFUser = PFUser.currentUser()!
    var manager: BNCManager
    
    init(manager: BNCManager) {
        self.manager = manager
    }
    
    func checkBunch(bunch: BNCBunch) {
        guard bunch.online == true else { return }
        
        let query = PFQuery(className: GetUniversity().parseDBName())
        query.whereKey("objectId", equalTo: bunch.PFBunch.objectId!)
        query.getFirstObjectInBackgroundWithBlock {
            (object, error) -> Void in
            if let _ = error {
                if error!.code == PFErrorCode.ErrorObjectNotFound.rawValue {
                    self.removeAndHideBunch(bunch)
                } else {
                    //no internet??
                }
            } else {
                // 2: Does it pass filters?
                let qos = QOS_CLASS_BACKGROUND
                let queue = dispatch_get_global_queue(qos, 0)
                dispatch_async(queue) {
                    let pass = self.manager.filter.essentialFilterTest(bunch)
                    dispatch_async(dispatch_get_main_queue()) {
                        if !pass {
                            self.removeAndHideBunch(bunch)
                        }
                    }
                }
                
                
            }
        }
    }
    
    func validateBunchForCheckIn(bunch: BNCBunch) {
        if manager.filter.essentialFilterTest(bunch) {
            PFDelegate().checkInToBunch(bunch)
        } else {
            manager.error.showErrorWithMessage(BNCErrorMessage.BunchNoLongerAvailable)
        }
    }
    
    func checkActiveBunch() {
        // 1: Is the bunch still online?
        let bunch = manager.activeBunch!
        guard bunch.online == true else { return }
        
        let query = PFQuery(className: GetUniversity().parseDBName())
        query.whereKey("objectId", equalTo: bunch.PFBunch.objectId!)
        query.getFirstObjectInBackgroundWithBlock {
            (object, error) -> Void in
            if let _ = error {
                if error!.code == PFErrorCode.ErrorObjectNotFound.rawValue {
                    self.endActiveBunchRelationship()
                } else {
                    //no internet??
                }
            } else {
                // 2: Is the user checked in?
                if let checkedIn = object!.valueForKey("checkedIn") as? [PFUser] {
                    if checkedIn.contains(self.user) {
                    } else {
                        self.endActiveBunchRelationship()
                    }
                }
            }
        }
    }
    
    func endActiveBunchRelationship() {
        manager.endActiveBunchRelationship()
    }
    
    func removeAndHideBunch(bunch: BNCBunch) {
        manager.removeAndHideBunch(bunch)
    }
}