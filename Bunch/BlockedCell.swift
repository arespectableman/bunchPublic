//
//  BlockedCell.swift
//  Bunch
//
//  Created by David Woodruff on 2015-11-03.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import UIKit
import Spring

class BlockedCell: UITableViewCell, SuccessFailure {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unblockButton: DesignableButton!
    
    var parent: BlockedViewController!
    var email: String?
    
    @IBAction func unblockAction(sender: AnyObject) {
        PFDelegate().unblockUserWithEmail(email!, sender: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func success() {
        parent.success()
    }
    
    func failure(message: String?) {
        parent.failure(message)
    }

}
