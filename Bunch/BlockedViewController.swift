//
//  BlockedViewController.swift
//  Bunch
//
//  Created by David Woodruff on 2015-11-03.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import UIKit
import Parse

class BlockedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SuccessFailure {

    @IBAction func blockViaEmailAction(sender: AnyObject) {
        var alertView = UIAlertController()
        alertView = UIAlertController(title: "Block User", message: "Enter an email:", preferredStyle: .Alert)
        
        alertView.addTextFieldWithConfigurationHandler({ (textField) -> Void in })
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        alertView.addAction(UIAlertAction(title: "Block", style: .Destructive, handler: { (alertAction) -> Void in
            let textField = alertView.textFields![0] as UITextField
            PFDelegate().blockUserWithEmail(textField.text!, sender: self)
        }))

        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var blockedUsers: [PFUser] = [] {
        didSet {
            self.tableView.reloadData() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Blocked"
        PFDelegate().getBlockedUserList(self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! BlockedCell
        cell.parent = self
        blockedUsers[indexPath.row].fetchIfNeededInBackgroundWithBlock {
            (success: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                cell.nameLabel.text = self.blockedUsers[indexPath.row]["name"] as? String
                cell.email = self.blockedUsers[indexPath.row]["email"] as? String
            } else {
                print(error)
            }
        }
        return cell
    }
    
    func success() {
        PFUser.currentUser()!.fetchIfNeededInBackgroundWithBlock {
            (success: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                PFDelegate().getBlockedUserList(self)
            } else {
                print(error)
            }
        }
    }
    
    func failure(message: String?) {
        let alert = EasyAlert().alertWithTitleAndMessage(message: message!)
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
