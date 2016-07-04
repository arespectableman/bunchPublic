
//
//  BunchButton.swift
//  Bunch
//
//  Created by David Woodruff on 2015-10-24.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation
import Spring

enum BunchButtonState {
    case FutureActive
    case FutureCreate
    case PresentActive
    case PresentCreate
}

class BunchButton: SpringButton {
    
    var homeVC: HomeViewController!
    
    func initUI(home: HomeViewController) {
        self.imageView?.contentMode = .ScaleAspectFit
        self.homeVC = home
        
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 2
        
        self.animation = "zoomIn"
        self.duration = 0.7
        self.animate()
    }
    
    func show() {
        self.determineState()
        self.animation = "slideLeft"
        self.damping = 1
        self.velocity = 1
        self.duration = 0.3
        self.animate()
        self.userInteractionEnabled = true
    }
    
    func hide() {
        guard self.alpha > 0 else { return }
        self.animation = "zoomOut"
        self.duration = 0.3
        self.animate()
        self.userInteractionEnabled = false
    }
    
    
    func pop() {
        self.animation = "pop"
        self.duration = 0.25
        self.animate()
    }
    
    func beginPan() {
        self.animation = "pop"
        self.duration = 0.25
        self.animate()
        self.iconForState(.FutureCreate)
    }
    
    func determineState() {
        if homeVC!.activeBunch == nil {
            iconForState(.PresentCreate)
        } else if homeVC!.activeBunch!.type == "present" {
            iconForState(.PresentActive)
        } else {
            iconForState(.FutureActive)
        }
    }
    
    private func iconForState(state: BunchButtonState) {
        switch state {
        case .FutureActive:
            let pin = BNCImage.orangePin!
            let icon = homeVC.activeBunch!.icon
            
            guard icon != nil else {
                self.setImage(pin, forState: .Normal)
                return
            }
            
            let pinicon = homeVC.manager.piniconManager.getFullPiniconForIconNameWithPin(name: icon, pin: pin)
            self.setImage(pinicon, forState: .Normal)
            
        case .FutureCreate:
            self.setImage(BNCImage.orangePinCreate, forState: .Normal)
            
        case .PresentActive:
            let pin = BNCImage.greenPin!
            let icon = homeVC.activeBunch!.icon
            
            guard icon != nil else {
                self.setImage(pin, forState: .Normal)
                return
            }
            
            let pinicon = homeVC.manager.piniconManager.getFullPiniconForIconNameWithPin(name: icon, pin: pin)
            self.setImage(pinicon, forState: .Normal)
            
        case .PresentCreate:
            self.setImage(BNCImage.greenPinCreate, forState: .Normal)
        }
    }
}
