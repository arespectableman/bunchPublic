//
//  BSKTableView.swift
//  Bunch
//
//  Created by David Woodruff on 2015-10-28.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import UIKit
import Spring

//class BasketTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
//    
//    
//    var parent: BasketViewController!
//    
//    var presentFilter: Bool = true
//    var futureFilter: Bool = true
//    
//    func load() {
//        self.delegate = self
//        self.dataSource = self
//        self.allowsMultipleSelection = true
//        getFilters()
//    }
//
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return baskets.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("basket")! as! BasketCell
//        
//        switch baskets[indexPath.row] {
//        case "present":
//            cell.basketImageView.image = BNCImage.greenPOM
//            cell.selected = presentFilter
//        case "future":
//            cell.basketImageView.image = BNCImage.orangePOM
//            cell.selected = futureFilter
//        default: break
//        }
//        cell.selectionStyle = .None
//        cell.backgroundColor = UIColor.clearColor()
//        cell.label.text = baskets[indexPath.row].capitalizedString
//        return cell
//    }
//    
//    func getFilters() {
//        presentFilter = parent.parent.manager.filter.showPresent
//        futureFilter = parent.parent.manager.filter.showFuture
//    }
//
//}
