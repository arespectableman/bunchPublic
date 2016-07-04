//
//  FilterTableViewController.swift
//  Bunch
//
//  Created by David Woodruff on 2015-11-02.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import UIKit
import Spring

class FilterTableViewController: UITableViewController {

    @IBOutlet weak var presentCell: FilterCell! { didSet { presentCell.backgroundColor = UIColor.clearColor() } }
    @IBOutlet weak var futureCell: FilterCell! { didSet { futureCell.backgroundColor = UIColor.clearColor() } }
    
    var visible: Bool = false
    var filterCells = Set<FilterCell>()
    var homeVC: HomeViewController!
    var filterDelegate: BNCFilterDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        insertBlurView(self.view, style: .ExtraLight)
        self.view.layer.cornerRadius = 10
        filterCells = [futureCell, presentCell]
        for cell in filterCells {
            cell.homeVC = homeVC
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.frame.origin.x = homeVC.view.frame.width
    }
    
    func show() {
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.view.frame.origin.x = (self.homeVC.view.frame.origin.x+self.view.frame.width)
                - self.view.frame.width
            }, completion: { _ in self.homeVC.containerView.userInteractionEnabled = true })
        visible = true
    }
    
    func hide() {
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.view.frame.origin.x = (self.homeVC.view.frame.origin.x+self.view.frame.width)
                + self.view.frame.width
            }, completion: { _ in self.homeVC.containerView.userInteractionEnabled = false })
        visible = false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? FilterCell
        didSelectCell(cell!)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? FilterCell
        didDeselectCell(cell!)
    }
    
    func importFilters(filters: Set<BNCFilterProperty>) {
        for filter in filters {
            switch filter {
            case .Present:
                presentCell.setSelected(true, animated: true)
            case .Future:
                futureCell.setSelected(true, animated: true)
            default: break
            }
        }
    }
    
    // do I have to do everything around here myself?
    func didSelectCell(cell: FilterCell) {
        cell.animateSelected()
        avoidNilMapWithCellSelected(cell)
        switch cell {
        case presentCell:
            filterDelegate.addFilterProperty(.Present)
        case futureCell:
            filterDelegate.addFilterProperty(.Future)
        default: break
        }
    }
    
    func didDeselectCell(cell: FilterCell) {
        cell.animateDeselected()
        switch cell {
        case presentCell:
            filterDelegate.removeFilterProperty(.Present)
        case futureCell:
            filterDelegate.removeFilterProperty(.Future)
        default: break
        }
    }
    
    func deselectAllCells() {
        for (var i = 0; i < filterCells.count; i++) {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? FilterCell
            cell?.setSelected(false, animated: false)
            didDeselectCell(cell!)
        }
    }
    
    func avoidNilMapWithCellSelected(cell: FilterCell)  {
        var tempSet = filterCells; tempSet.remove(cell)
        for filterCell in tempSet {
            if !filterCell.selected {
                return
            }
        }
        for cell in tempSet { //unselect a different cell instead MUAHAHAHAHAHAH
            tableView.deselectRowAtIndexPath(tableView.indexPathForCell(cell)!, animated: false)
            didDeselectCell(cell)
            return
        }
        return
    }
    
}
