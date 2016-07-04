//
//  CustomPiniconViewController.swift
//  Bunch
//
//  Created by David Woodruff on 2015-11-24.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation
import Spring

class CustomPiniconViewController: UIViewController {

    @IBOutlet weak var explainerView: UITextView! {
        didSet {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 7
            let attributes = [NSParagraphStyleAttributeName : style]
            explainerView.attributedText = NSAttributedString(string: explainerView.text, attributes:attributes)
        }
    }
    
    override func viewDidLoad() {
        explainerView.layer.cornerRadius = 5
        explainerView.clipsToBounds = true
        explainerView.textContainerInset = UIEdgeInsetsMake(30, 25, 30, 25)
        explainerView.font = UIFont(name: explainerView.font!.fontName, size: 13)
        explainerView.textColor = UIColor.darkGrayColor()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        let point = touch.locationInView(self.view)
        if !explainerView.frame.contains(point) {
            if let nvc = presentingViewController as? UINavigationController {
                if let uvc = nvc.topViewController as? UserViewController {
                    uvc.coverView?.setAlphaAnimated(0)
                }
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}