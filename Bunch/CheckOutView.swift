//
//  CheckOutView.swift
//  Bunch
//
//  Created by David Woodruff on 2015-10-25.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation

class CheckOutView: UtilityView {
    
    @IBAction func checkOut(sender: AnyObject) {
        if let pvc = self.parentViewController as? BunchViewController {
            self.pop()
            pvc.startAction(.CheckOut)
        }
    }
}