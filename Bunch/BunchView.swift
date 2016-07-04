//
//  BunchView.swift
//  Bunch
//
//  Created by David Woodruff on 2015-10-24.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation
import Spring

class BunchView: SpringView {
    
    func load() {
        self.layer.shadowOffset = CGSize(width: 2, height: 3)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 3
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.whiteColor().CGColor
        insertBlurView(self, style: UIBlurEffectStyle.ExtraLight)
    }
}