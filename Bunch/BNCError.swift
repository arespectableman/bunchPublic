//
//  BNCError.swift
//  Bunch
//
//  Created by David Woodruff on 2015-11-09.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation

class BNCError {
    var manager: BNCManager
    
    init(manager: BNCManager) {
        self.manager = manager
    }
    
    func showErrorWithMessage(message: String) {
        let alert = EasyAlert().alertWithTitleAndMessage(message: message)
        let vc = UIApplication.sharedApplication().delegate?.window!?.rootViewController
        if let nvc = vc as? UINavigationController {
            nvc.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func showErrorWithMessageOnBunchVC(message: String) {
        let alert = EasyAlert().alertWithTitleAndMessage(message: message)
        let vc = UIApplication.sharedApplication().delegate?.window!?.rootViewController
        if let nvc = vc as? UINavigationController {
            if let vvc = nvc.visibleViewController as? BunchViewController {
                vvc.presentViewController(alert, animated: true, completion: nil)
            } else {
                nvc.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}