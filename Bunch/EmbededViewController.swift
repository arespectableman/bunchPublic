////
////  EmbededViewController.swift
////  Bunch
////
////  Created by David Woodruff on 2015-11-02.
////  Copyright © 2015 Jukeboy. All rights reserved.
////
//
//import UIKit
//
//class EmbededViewController: UIViewController {
//    
//    var homeVC: HomeViewController!
//    var visible: Bool = false
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.definesPresentationContext = true
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        self.view.frame.origin.x = homeVC.view.frame.width
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        performSegueWithIdentifier(Segue.EmbededToFilter, sender: self)
//    }
//    
//    func show() {
//        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
//            self.view.frame.origin.x = (self.homeVC.view.frame.origin.x+self.view.frame.width)
//                - self.view.frame.width
//            }, completion: nil)
//        visible = true
//    }
//    
//    func hide() {
//        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
//            self.view.frame.origin.x = (self.homeVC.view.frame.origin.x+self.view.frame.width)
//                + self.view.frame.width
//            }, completion: nil)
//        visible = false
//    }
//
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == Segue.EmbededToFilter {
//            if let dvc = segue.destinationViewController as? FilterTableViewController {
//                dvc.homeVC = self.homeVC
//            }
//        }
//    }
//    
//    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
//        return UIModalPresentationStyle.None
//    }
//}
