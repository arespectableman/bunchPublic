//
//  BNCUsability.swift
//  Bunch
//
//  Created by David Woodruff on 2015-10-31.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation


protocol BNCUsabilityDelegate {
    var usable: Bool { get }
    func addUsabilitySubviewNamed(name: String)
    func removeUsabilitySubview()
}

struct UsabilityNib {
    static let Location = "Location"
    static let Internet = "Internet"
}

class BNCUsability {
    
    var usable: Bool {
        get {
            return internet && location
        }
    }
    
    private var internet: Bool = false
    private var location: Bool = false
    private var delegate: BNCUsabilityDelegate
    let reachability: Reachability
    
    init(delegate: BNCUsabilityDelegate) {
        self.delegate = delegate
        reachability = Reachability.reachabilityForInternetConnection()!
        self.internet = reachability.isReachable()
        start()
    }
    
    func internetUsable() {
        internet = true
        hideInternetSubview()
    }
    
    func locationUsable() {
        location = true
        hideLocationSubview()
    }
    
    func internetUnusable() {
        internet = false
        showInternetSubview()
    }
    
    func locationUnusable() {
        location = false
        showLocationSubview()
        
    }
    
    func showInternetSubview() {
        delegate.addUsabilitySubviewNamed(UsabilityNib.Internet)
    }
    
    func showLocationSubview() {
        delegate.addUsabilitySubviewNamed(UsabilityNib.Location)
    }
    
    func hideInternetSubview() {
        delegate.removeUsabilitySubview()// remove primary error
        if !location { // check for secondary error
            showLocationSubview()
        }
    }
    
    func hideLocationSubview() {
        delegate.removeUsabilitySubview() // remove primary error
        if !internet { // check for secondary error
            showInternetSubview()
        }
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        if reachability.isReachable() {
            internetUsable()
        } else {
            internetUnusable()
        }
    }
    
    @objc func locationChanged(note: NSNotification) {
        let newLocationValid = note.object as! Bool
        if newLocationValid {
            locationUsable()
        } else {
            locationUnusable()
        }
    }
    
    func start() {
        reachability.startNotifier()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:",
            name: ReachabilityChangedNotification, object: reachability)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationChanged:",
            name: BNCNotification.locationUpdated, object: nil)


    }
    
    
    func stop() {
        reachability.stopNotifier()
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: ReachabilityChangedNotification, object: nil)
    }
    
    deinit {
        stop()
    }
}