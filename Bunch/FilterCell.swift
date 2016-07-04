//
//  BasketCell.swift
//  Bunch
//
//  Created by David Woodruff on 2015-10-29.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import UIKit
import Spring

class FilterCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: SpringImageView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var labelView: UIView!
    
    @IBAction func containerSwiped(sender: AnyObject) {
        homeVC.hideFilterViewController()
    }
    var homeVC: HomeViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func animateSelected() {
        self.setAlphaAnimated(0.35)
    }
    
    func animateDeselected() {
        iconImageView.animation = "pop"
        iconImageView.duration = 0.25
        iconImageView.animate()
        self.setAlphaAnimated(1)
    }

}
