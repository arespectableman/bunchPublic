//
//  CheckInButton.swift
//  Bunch
//
//  Created by David Woodruff on 2015-10-25.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation

class CheckInView: UtilityView {
    
    @IBAction func checkIn(sender: AnyObject) {
        if let pvc = self.parentViewController as? BunchViewController {
            self.pop()
            pvc.preScreenAction(.CheckIn)
        }
    }
}