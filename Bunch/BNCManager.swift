//
//  BNCManager.swift
//  Bunch
//
//  Created by David Woodruff on 2015-10-22.
//  Copyright © 2015 Jukeboy. All rights reserved.
//
//
//  This class houses the current list of bunches retireved from the database
//  BL will notify MapView of bunches to add, or takeaway
//  Given a set of requirements (baskets or other), BL will change what is on display

import Foundation
import Parse

class BNCManager: NSObject, BNCFilterDelegate, BNCLocationManagerDelegate, BNCUsabilityDelegate {
    
    // Controllers
    var mapView: MapView!
    var homeVC: HomeViewController!
    
    // Models
    var filter: BNCFilter!
    var usability: BNCUsability!
    var locationManager: BNCLocationManager!
    var attendance: BNCAttendance!
    var error: BNCError!
    var piniconManager: BNCPiniconManager!
    
    // variables
    let user = PFUser.currentUser()
    var activeBunch: BNCBunch? {
        didSet {
            homeVC.bunchButton.determineState()
            if oldValue != nil { homeVC.mapView.updateAnnotationForBunch(oldValue!) }
            if activeBunch != nil { homeVC.mapView.updateAnnotationForBunch(activeBunch!) }
        } }
    var unfilteredBunches = Set<BNCBunch>()
    var filteredBunches = Set<BNCBunch>()
    
    // initialization
    init(homeVC: HomeViewController, mapView: MapView) {
        super.init()
        // init controllers
        self.mapView = mapView
        self.homeVC = homeVC
        
        // init models
        self.filter = BNCFilter(manager: self)
        self.usability = BNCUsability(delegate: self)
        self.locationManager = BNCLocationManager(manager: self)
        self.attendance = BNCAttendance(manager: self)
        self.error = BNCError(manager: self)
        self.piniconManager = BNCPiniconManager(manager: self)
        
        
        // foreground/background notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidEnterBackground", name: BNCNotification.backgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillEnterForeground", name: BNCNotification.foregroundNotification, object: nil)
        startTimer()
        
        self.getBunches()
    }
    
    
    //
    // Location Manager Delegate
    //
    
    var userLocation: CLLocation? {
        get {
            return locationManager.userLocation
        }
    }
    
    var userLocationValid: Bool {
        get {
            return locationManager.userLocationValid
        }
    }
    
    func locationValid(coord: CLLocationCoordinate2D) -> Bool {
        return locationManager.locationValid(coord)
    }
    
    
    //
    // BNCUsabilityDelegate
    //
    
    var usable: Bool {
        get {
            return usability.usable
        }
    }
    
    func addUsabilitySubviewNamed(name: String) {
        homeVC.addUsabilitySubviewNamed(name)
    }
    
    func removeUsabilitySubview() {
        homeVC.removeUsabilitySubview()
    }
    
    
    //
    // BUNCH RETRIEVE AND FILTER
    //
    
    func getBunches() {
        PFDelegate().getBunchesFromParse(self)
    }
    
    func handleParseObjects(parseObjects: [PFObject]) {
        var unfilteredSet = Set<BNCBunch>()
        for parseObject in parseObjects {
            let bunch = BNCBunch(bunch: parseObject, manager: self)
            unfilteredSet.insert(bunch)
            // Detect if it is joined or not
            if let participants = parseObject["checkedIn"] as? [PFUser] {
                if participants.contains(user!) && activeBunch == nil {
                    activeBunch = bunch
                }
            }
        }
        unfilteredBunches = unfilteredSet
        filter.filterBunches(unfilteredBunches)
    }
    
    func handleFiltrate(bunch: BNCBunch) {
        mapView.handleFiltrate(bunch)
    }
    
    func handleFiltrate(bunches: Set<BNCBunch>) {
        filteredBunches = bunches
        mapView.handleFiltrate(bunches)
    }
    
    func removeBunch(bunch: BNCBunch) {
        if bunch == activeBunch {
            activeBunch = nil
        }
        unfilteredBunches.remove(bunch)
        filteredBunches.remove(bunch)
        mapView.handleFiltrate(filteredBunches)
    }
    
    func bunchAddedToMap(bunch: BNCBunch) {
        unfilteredBunches.insert(bunch)
        filteredBunches.insert(bunch)
        activeBunch = bunch
    }
    
    
    //
    // BNC Attendance
    //
    
    func endActiveBunchRelationship(includeError: Bool = true) {
        guard activeBunch != nil else { return }
        removeBunch(activeBunch!)
        activeBunch = nil
        homeVC.bunchVC?.hide()
        if includeError {
            error.showErrorWithMessage(BNCErrorMessage.ActiveBunchNoLongerAvailable)
        }
    }
    
    func removeAndHideBunch(bunch: BNCBunch) {
        removeBunch(bunch)
        homeVC.bunchVC?.hide()
        error.showErrorWithMessage(BNCErrorMessage.BunchNoLongerAvailable)
    }
    
    //
    //  UPDATE TIMER
    //
    
    var timer: NSTimer?
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "refresh", userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func refresh() {
        if !locationManager.userLocationValid { usability.locationUnusable() }
        if locationManager.started == false {
            if user!["onboarded"] as? Bool == true {
                locationManager.start()
            }
        }
        
        if activeBunch != nil { attendance.checkActiveBunch() }
        
        if homeVC.bunchVC != nil {
            let bunch = homeVC.bunchVC!.bunch
            if bunch != activeBunch {
                attendance.checkBunch(bunch)
            }
        }
        
        let vc = UIApplication.sharedApplication().delegate?.window!?.rootViewController
        if let nvc = vc as? UINavigationController {
            if let _ = nvc.visibleViewController as? HomeViewController {
                getBunches()
            }
            homeVC.bunchVC?.refresh()
        }
    }
    
    func logout() {
        homeVC.logout()
    }
    
    //
    //  BNCFilterDelegate
    //
    
    func addFilterProperty(property: BNCFilterProperty) {
        filter.addProperty(property)
        filter.filterBunches(unfilteredBunches)
    }
    
    func removeFilterProperty(property: BNCFilterProperty) {
        filter.removeProperty(property)
        filter.filterBunches(unfilteredBunches)
    }
    
    func getActiveFilters() -> Set<BNCFilterProperty> {
        return filter.activeFilters
    }
    
    //
    // BNCPiniconManager
    //
    
    //
    //  Foreground and Background Schtuff
    //
    
    func appDidEnterBackground() {
        stopTimer()
        usability.stop()
        locationManager.stop()
    }
    
    func appWillEnterForeground() {
        startTimer()
        usability.start()
        locationManager.start()
    }
    
    
    deinit {
        stopTimer()
        usability.stop()
        locationManager.stop()
        NSNotificationCenter.defaultCenter().removeObserver(BNCNotification.foregroundNotification)
        NSNotificationCenter.defaultCenter().removeObserver(BNCNotification.backgroundNotification)
    }
}