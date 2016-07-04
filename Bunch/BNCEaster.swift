//
//  BNCEaster.swift
//  Bunch
//
//
//  Created by David Woodruff on 2015-11-25.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation
import Parse

class BNCEaster {
    
    private var recentlySelected = [String]()
    private let powerUnlock = ["look","game","brain"]
    
    func didSelectItem(item: String) {
        recentlySelected.insert(item, atIndex: 0)
        if recentlySelected.count >= 4 {
            recentlySelected.removeLast()
        }
        checkForEggs()
    }
    
    private func checkForEggs() {
        if recentlySelected == powerUnlock {
            PFUser.currentUser()?.addUniqueObject("power", forKey: "piniconPermissions")
            PFUser.currentUser()?.saveInBackground()
        }
    }
}