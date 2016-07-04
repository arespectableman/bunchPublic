//
//  BNCAnnotation.swift
//
//  Created by David Woodruff on 2015-06-10.
//  Copyright (c) 2015 Spaced Out Tech. All rights reserved.
//

import UIKit
import MapKit
import Parse

class BNCAnnotation: NSObject, MKAnnotation {
    
    var bunch: BNCBunch!
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var icon: UIImage?

    
    init (coord: CLLocationCoordinate2D, bunch: BNCBunch) {
        self.coordinate = coord
        self.title = "bunch"
        self.bunch = bunch
        super.init()
    }
}