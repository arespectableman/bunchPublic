//
//  BunchViewController.swift
//  Bunch
//
//  Created by David Woodruff on 2015-10-25.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import UIKit
import Spring
import AKPickerView_Swift

enum Utility {
    case CheckIn
    case CheckOut
    case Save
    case Renew
    case CreateInvalid
    case CreateValid
}

class BunchViewController: UIViewController, Refreshable, AKPickerViewDelegate, AKPickerViewDataSource {
    
    var bunch: BNCBunch!
    var tabBar: BunchTabBarController!
    var keyboardIsShown: Bool = false
    
    @IBOutlet weak var bunchView: BunchView!
    @IBOutlet weak var bunchViewCenterYConstraint: NSLayoutConstraint!
    
    var utilityView: UtilityView? { didSet {
        guard utilityView != nil else { return }
        utilityView!.initUI()
        if let _ = utilityView as? CreateValidView {
            utilityView!.getAttention()
        }
        else { utilityView?.show() }
        } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bunchView.load()
        if bunch.online { bunch.fetch() }
        utilityView = nil
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        guard utilityView == nil else { return }
        loadInitialUtility()
        switch bunch.relation {
        case .Creator: loadPiniconUI()
        default: hidePiniconUI()
        }
    }
    
    //
    //  UTILITY MGMT
    //
    
    func loadInitialUtility() {
        var utility: Utility!
        switch bunch.relation {
        case .Creator:
            utility = .CreateInvalid
        case .Viewer:
            utility = .CheckIn
        case .Attendee:
            utility = .CheckOut
        case .Host:
            if bunch.type == "future" { return }
            utility = .Renew
        }
        loadUtility(utility)
    }
    
    func loadUtility(utility: Utility) {
        if utilityView != nil { utilityView!.removeFromSuperview() }
        var newView: UtilityView!
        switch utility {
        case .CheckIn:
            newView = UIView.loadFromNibNamed("CheckIn") as? CheckInView
        case .CheckOut:
            newView = UIView.loadFromNibNamed("CheckOut") as? CheckOutView
        case .Save:
            newView = UIView.loadFromNibNamed("Save") as? SaveView
        case .CreateValid:
            newView = UIView.loadFromNibNamed("CreateValid") as? CreateValidView
        case .CreateInvalid:
            newView = UIView.loadFromNibNamed("CreateInvalid") as? CreateInvalidView
        case .Renew:
            newView = UIView.loadFromNibNamed("Renew") as? RenewView
        }
        
        utilityView = newView
        view.insertSubview(utilityView!, aboveSubview: self.view)
        utilityView?.userInteractionEnabled = true
        utilityView!.translatesAutoresizingMaskIntoConstraints = false
        let vertConstraint = NSLayoutConstraint(item: utilityView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: bunchView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 12)
        let horizontalConstraint = NSLayoutConstraint(item: utilityView!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: utilityView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 300)
        let heightConstraint = NSLayoutConstraint(item: utilityView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 50)
        view.addConstraint(vertConstraint)
        view.addConstraint(horizontalConstraint)
        view.addConstraint(widthConstraint)
        view.addConstraint(heightConstraint)
    
    }
    
    //
    //  ACTION STARTING AND FINISHING
    //
    
    func preScreenAction(action: PFDelegateAction) {
        switch action{
        case .Create:
            startAction(action)
            return
        default:
            let joinedBunch = self.bunch.manager.activeBunch
            if joinedBunch == nil {
                startAction(action)
                return
            }
        }
        let alertView = EasyAlert().alertWithTitleAndMessage(BNCString.WarningTitle, message: BNCString.WarningMessage)
        presentViewController(alertView, animated: true, completion: nil)

    }
    
    func startAction(action: PFDelegateAction) {
        switch action {
        case .CheckIn:
            bunch.checkIn()
        case .CheckOut:
            bunch.checkOut()
        case .Renew:
            bunch.renew()
        case .Create:
            hidePiniconUI()
            let info = tabBar.getInfoFromTabs()
            bunch.blurb = info[0] as? String
            switch bunch.type! {
            case "present":
                bunch.time = NSDate()
            case "future":
                bunch.time = info[1] as? NSDate
            default: break
            }
            bunch.icon = selectedPiniconName
            bunch.create()
        case .Save:
            for vc in tabBar.viewControllers! {
                if let saveVC = vc as? Saveable {
                    saveVC.prepForSave()
                }
            }
            bunch.save()
        default: break
        }
        utilityView!.startActivity()
    }
    
    func finishActionWithSuccess(action: PFDelegateAction, success: Bool) {
        switch action {
        case .CheckIn:
            if success {
                tabBar.updateToCheckedIn()
                loadUtility(.CheckOut)
            }
        case .CheckOut:
            if success { hide() }
        case .Renew:
            ()
        case .Create: ()
            if success { hide() }
            else { showPiniconUI() }
        case .Save:
            if success {
                utilityView?.hide()
                if bunch.type! == "present" { loadUtility(.Renew) }
            }
        case .Fetch:
            if success {
                if let svc = tabBar.selectedViewController as? Refreshable {
                    svc.refresh()
                }
            }
        default: break
        }
        guard utilityView != nil else { return }
        utilityView?.stopActivity()
    }
    
    //
    // Pinicon, PickerView and Friends
    //
    
    var pickerView: AKPickerView? {
        didSet {
            pickerView?.delegate = self
            pickerView?.dataSource = self
            pickerView?.interitemSpacing = 35
        }
    }
    var availablePiniconNames = [String]()
    var selectedPiniconName: String?
    var pickerViewXConstraint: NSLayoutConstraint!
    var easter: BNCEaster?
    
    private func loadPiniconUI() {
        easter = BNCEaster()
        availablePiniconNames = bunch.manager.piniconManager.createablePiniconNames
        let bunchVCMidPoint = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        let bunchPoint = CGPointMake(bunchVCMidPoint.x, bunchVCMidPoint.y+self.view.frame.height*BNCNum.MapBunchOffset)
        pickerView = AKPickerView(frame: CGRectMake(bunchView.frame.origin.x,
            bunchPoint.y-9, // #magicnumbahs
            bunchView.frame.width-11,
            BNCIcon.pride!.size.height
            ))
        pickerView!.selectItem(4) //is the "look" pinicon
        pickerView!.alpha = 0
        self.view.addSubview(pickerView!)
        pickerView!.setAlphaAnimated(1)
    }
    
    private func hidePiniconUI() {
        pickerView?.setAlphaAnimated(0)
    }
    
    private func showPiniconUI() {
        pickerView?.setAlphaAnimated(1)
    }
    
    func pickerView(pickerView: AKPickerView, imageForItem item: Int) -> UIImage {
        let piniconName = availablePiniconNames[item]
        return bunch.manager.piniconManager.getPiniconFromName(piniconName)
    }
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        selectedPiniconName = availablePiniconNames[item]
        easter?.didSelectItem(selectedPiniconName!)
        
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return availablePiniconNames.count
    }
    
    //
    // USER INTERFACE
    //
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        let point = touch.locationInView(self.view)
        
        guard !keyboardIsShown else { self.view.endEditing(true); return }
        
        if pickerView != nil {
            if pickerView!.alpha > 0 {
                let xExtension: CGFloat = 10
                let yExtension: CGFloat = 20
                let extendedPickerViewRect = CGRectMake(pickerView!.frame.origin.x-xExtension,
                    pickerView!.frame.origin.y-yExtension,
                    pickerView!.frame.width + (xExtension*2),
                    pickerView!.frame.height + (yExtension*2))
                guard !extendedPickerViewRect.contains(point) else { return }
            }
        }

        if !bunchView.frame.contains(point) {
            if tabBar.checkBunchPartialValidity() {
                let alertView = UIAlertController(title: "Cancel Bunch?", message: "This will end creation of the bunch", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
                alertView.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: {(alert: UIAlertAction!) in self.hide()}))
                presentViewController(alertView, animated: true, completion: nil)
            } else {
                if bunch!.relation == .Host || bunch!.relation == .Attendee {
                    self.hide()
                } else {
                    self.hide()
                }
            }
        }
    }
    
    func keyboardWillShow() {
        if !keyboardIsShown {
            self.bunchViewCenterYConstraint.constant -= BNCNum.keyboardFrameOffset
            UIView.animateWithDuration(0.15, animations: {
                self.view.layoutIfNeeded()
            })
            keyboardIsShown = true
        }
    }
    
    func keyboardWillHide() {
        if keyboardIsShown {
            self.bunchViewCenterYConstraint.constant += BNCNum.keyboardFrameOffset
            UIView.animateWithDuration(0.15, animations: {
                self.view.layoutIfNeeded()
            })
            keyboardIsShown = false
        }
    }
    
    //
    // REFRESH
    //
    
    func refresh() {
        if bunch.online {
            bunch.fetch()
        }
    }
    
    //
    // SEGUES MGMT
    //
    
    func hide() {
        bunchView.animation = "fadeOut"
        utilityView?.hide()
        bunchView.animateTo()
        performSegueWithIdentifier(Segue.BunchToHome, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Segue.ContainerToTabBar:
                if let dvc = segue.destinationViewController as? BunchTabBarController {
                    dvc.parent = self
                    dvc.bunch = self.bunch
                    self.tabBar = dvc
                }
            default: break
            }
        }
    }
}
