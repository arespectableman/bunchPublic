//
//  BasketViewController.swift
//  Bunch
//
//  Created by David Woodruff on 2015-10-28.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import UIKit
import Spring

//class BasketViewController: UIViewController {
//
//    @IBOutlet weak var springView: SpringView!
//    
//    @IBOutlet weak var tableView: BasketTableView! {
//        didSet {
//            tableView.parent = self
//        }
//    }
//    
//    override func viewDidLoad() {
//        tableView.load()
//    }
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let touch = touches.first as UITouch!
//        let point = touch.locationInView(self.view)
//        
//        if !springView.frame.contains(point) {
//            hideViewController()
//        }
//    }
//    
//    func hideViewController() {
//        springView.animation = "slideLeft"
//        springView.animateTo()
//        //springView.animateNext({ })
//        self.performSegueWithIdentifier("UnwindFromBasket", sender: self)
//    }
//
//    var parent: HomeViewController!
//    
//
//}
