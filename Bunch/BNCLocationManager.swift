//
//  BNCLocationManager.swift
//  Bunch
//
//  Created by David Woodruff on 2015-09-17.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation
import MapKit

protocol BNCLocationManagerDelegate {
    var userLocation: CLLocation? { get }
    var userLocationValid: Bool { get }
    func locationValid(coord: CLLocationCoordinate2D) -> Bool
    
}

class BNCLocationManager: CLLocationManager, CLLocationManagerDelegate {
    
    var manager: BNCManager!
    let uni = GetUniversity().determineUniversity()
    var started: Bool = false
    
    var userLocation: CLLocation? {
        get {
            return self.location
        }
    }
    
    var userLocationValid: Bool {
        get {
            if userLocation == nil {
                return false
            } else {
                return locationValid(userLocation!.coordinate)
            }
        }
    }
    
    func locationValid(coord: CLLocationCoordinate2D) -> Bool {
        return uni.coordinateIsInsideBounds(coord)
    }
    
    init(manager: BNCManager) {
        super.init()
        self.manager = manager
        self.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
                self.desiredAccuracy = kCLLocationAccuracyBest
                self.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let newLocationValid = locationValid(newLocation.coordinate)
        NSNotificationCenter.defaultCenter().postNotificationName(BNCNotification.locationUpdated, object: newLocationValid)
    }
    
    func stop() {
        self.stopUpdatingLocation()
        started = false
    }
    
    func start() {
        requestWhenInUseAuthorization()
        self.startUpdatingLocation()
        started = true
    }
}