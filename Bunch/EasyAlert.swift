//
//  EasyAlert.swift
//  Bunch
//
//  Created by David Woodruff on 2015-10-07.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation
import UIKit

struct AlertDefault {
    static let title = BNCString.AlertTitle
    static let message = "Something went terribily wrong"
}

class EasyAlert {

    func alertWithTitleAndMessage(title: String = AlertDefault.title, message: String = AlertDefault.message) -> UIAlertController {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        return alertView
    }
    
    
}