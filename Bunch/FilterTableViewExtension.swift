////
////  FilterTableViewExtension.swift
////  Bunch
////
////  Created by David Woodruff on 2015-11-02.
////  Copyright © 2015 Jukeboy. All rights reserved.
////
//
//import Foundation
//import Spring
//
//extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 2
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("filter") as! FilterCell
//        switch indexPath.row {
//        case 0:
//            presentCell = cell
//            presentCell.addSubview(UIView.loadFromNibNamed("PresentCell")!)
//        case 1:
//            futureCell = cell
//            futureCell.addSubview(UIView.loadFromNibNamed("FutureCell")!)
//        default: break
//        }
//        cell.backgroundColor = UIColor.clearColor()
//        insertBlurView(cell, style: .ExtraLight)
//        cell.selectionStyle = .None
//        addGradientViewForNoSelection(cell)
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        let filterCells = [presentCell, futureCell]
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        var numCellsSelected: Int = 0
//        for cell in filterCells { if cell!.selected { numCellsSelected += 1 } }
//        if numCellsSelected == filterCells.count-1 {
//            cell?.setSelected(false, animated: false)
//            return nil
//        }
//        return indexPath
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        addGradientViewForNoSelection(cell!)
//        switch cell! {
//        case presentCell:
//            manager.addFilterProperty(.Present)
//        case futureCell:
//            manager.addFilterProperty(.Future)
//        default: break
//        }
//    }
//    
//    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        addGradientViewForNoSelection(cell!)
//        switch cell! {
//        case presentCell:
//            manager.removeFilterProperty(.Present)
//        case futureCell:
//            manager.removeFilterProperty(.Future)
//        default: break
//        }
//    }
//    
//    func importFilters(filters: Set<BNCFilterProperty>) {
//        for filter in filters {
//            switch filter {
//            case .Present:
//                presentCell.setSelected(true, animated: true)
//            case .Future:
//                futureCell.setSelected(true, animated: true)
//            default: break
//            }
//        }
//    }
//    
//    func addGradientViewForNoSelection(cell: UITableViewCell) {
//        let gradientLayer = CAGradientLayer()
//        
//        filterGradientView.frame = cell.frame
//        gradientLayer.frame = filterGradientView.frame
//        let rightColor = UIColor(red: 0.53, green: 0.92, blue: 0.51, alpha: 1.0).CGColor as CGColorRef
//        let leftColor = UIColor(red: 0.53, green: 0.92, blue: 0.51, alpha: 0.2).CGColor as CGColorRef
//        gradientLayer.colors = [leftColor, rightColor]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
//        filterGradientView.layer.addSublayer(gradientLayer)
//        cell.insertSubview(filterGradientView, atIndex: 0)
//    }
//    
//    func addGradientViewForSelection(cell: UITableViewCell) {
//        let gradientLayer = CAGradientLayer()
//        
//        filterGradientView.frame = cell.frame
//        gradientLayer.frame = filterGradientView.frame
//        let rightColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).CGColor as CGColorRef
//        let leftColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).CGColor as CGColorRef
//        gradientLayer.colors = [leftColor, rightColor]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
//        filterGradientView.layer.addSublayer(gradientLayer)
//        cell.insertSubview(filterGradientView, atIndex: 0)
//    }
//    
//    func showFilterTable() {
//        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
//            self.filterTable.frame.origin.x = (self.view.frame.origin.x+self.view.frame.width)
//            - self.filterTable.frame.width
//            }, completion: nil)
//        filterTable.visible = true
//    }
//    
//    func hideFilterTable() {
//        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
//            self.filterTable.frame.origin.x = (self.view.frame.origin.x+self.view.frame.width)
//            + self.filterTable.frame.width
//            }, completion: nil)
//        filterTable.visible = false
//    }
//}