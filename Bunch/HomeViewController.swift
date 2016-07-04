//
//  MapViewController.swift
//  Bunch
//
//  Created by David Woodruff on 2015-08-11.
//  Copyright (c) 2015 Jukeboy. All rights reserved.
//

import UIKit
import MapKit
import Parse
import Spring
import CoreLocation
import QuartzCore

class HomeViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var bunchButton: BunchButton!
    
    @IBAction func handleBunchButtonTap(sender: UIGestureRecognizer) {
        guard manager.activeBunch == nil else { viewActiveBunch(self); return }
        guard usabilityDelegate.usable else { return }
        mapView.createBunchOfType("present", sender: sender)
    }
    
    @IBAction func handleBunchButtonPan(sender:UIPanGestureRecognizer) {
        guard activeBunch == nil else { viewActiveBunch(self); return }
        guard usabilityDelegate.usable else { return }
        if sender.state == .Began { bunchButton.beginPan() }
        let translation = sender.translationInView(self.view)
        if let view = sender.view {
            view.center = CGPoint(x:view.center.x + translation.x, y:view.center.y + translation.y)
        }
        sender.setTranslation(CGPointZero, inView: self.view)
        if sender.state == .Ended {
            mapView.createBunchOfType("future", sender: sender)
        }
    }
    
    var usabilityView: UIView?
    var keyboardIsShown: Bool = false
    var activeBunch: BNCBunch? {
        get { return manager.activeBunch }
    }
    
    var manager: BNCManager!
    var bunchVC: BunchViewController?
    var filterVC: FilterTableViewController!
    var usabilityDelegate: BNCUsabilityDelegate!

    func initUI() {
        mapView.initMap(self, locationManagerDelegate: manager)
        showNavigationBar()
        self.title = BNCString.NavBarDefaultTitle
        self.navigationItem.titleView?.tintColor = BNCColor.blue
    }
    
    func initModel() {
        manager = BNCManager(homeVC: self, mapView: mapView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usabilityDelegate = manager
        bunchButton.initUI(self)
        containerView.userInteractionEnabled = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidEnterBackground", name: BNCNotification.backgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillEnterForeground", name: BNCNotification.foregroundNotification, object: nil)
        initUI()
        let user = PFUser.currentUser()!
        if user.valueForKey("onboarded") as? Bool == false {
            performSegueWithIdentifier(Segue.HomeToWelcome, sender: self)
        }
        
    }
    
    // Bunch Selection Control
    
    func showUI() {
        bunchButton.show()
        self.title = BNCString.NavBarDefaultTitle
        showNavigationBar()
    }
    
    func hideUI() {
        bunchButton.hide()
        hideFilterViewController()
        hideNavigationBar()
    }
    
    func appDidEnterBackground() {
    }
    
    func appWillEnterForeground() {
        filterVC.deselectAllCells()
    }
    
    func logout() {
        performSegueWithIdentifier(Segue.HomeToLogin, sender: self)
        PFUser.logOut()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: BNCNotification.backgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: BNCNotification.foregroundNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        print("Did recieve memory warning")
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    
    //
    // MARK: UI Functions
    //
        
    func viewActiveBunch(sender: AnyObject) {
        guard activeBunch != nil else { return }
        mapView.selectBunch(activeBunch!)
    }
    
    
    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }

    //
    // Segues
    //
    
    func showBunch(bunch: BNCBunch) {
        performSegueWithIdentifier(Segue.HomeToBunch, sender: bunch)
    }

    @IBAction func unwindFromModal(segue:UIStoryboardSegue) {
        showUI()
        mapView.userInteractionEnabled = true
        switch segue.identifier! {
        case Segue.WelcomeToHome:
            manager.locationManager.requestWhenInUseAuthorization()
        case Segue.BunchToHome:
            if let svc = segue.sourceViewController as? BunchViewController {
                mapView.deselectBunch()
                if svc.bunch.relation == .Host {
                    self.performSelector("askForPushPermissionIfNeeded", withObject: nil, afterDelay: 2)
                }
                if !svc.bunch.online {
                    manager.endActiveBunchRelationship(false)
                }
                bunchVC = nil
            }
        default: break
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Segue.HomeToWelcome:
                if let dvc = segue.destinationViewController as? WelcomeViewController {
                    dvc.parent = self
                    dvc.modalPresentationStyle = .OverCurrentContext
                }
                
            case Segue.HomeToUser:
                if let nvc = segue.destinationViewController as? UINavigationController {
                    if let dvc = nvc.topViewController as? UserViewController {
                        dvc.homeVC = self
                    }
                }
            case Segue.HomeToBunch:
                if let dvc = segue.destinationViewController as? BunchViewController {
                    if let bunch = sender as? BNCBunch {
                        bunchVC = dvc
                        dvc.bunch = bunch
                        hideUI()
                    }
                }
            case Segue.HomeToFilter:
                if manager == nil {
                    initModel()
                }
                if let dvc = segue.destinationViewController as? FilterTableViewController {
                    filterVC = dvc
                    dvc.homeVC = self
                    dvc.filterDelegate = manager
                }
            default: break
            }
        }
    }
    
    
    func addUsabilitySubviewNamed(name: String) {
        if usabilityView == nil {
            bunchVC?.hide()
            usabilityView = UIView.loadFromNibNamed(name)
            usabilityView!.frame = self.view.frame
            insertBlurView(usabilityView!, style: .Dark)
            self.view.insertSubview(usabilityView!, aboveSubview: mapView)
            bunchButton.setAlphaAnimated(0.5)
        }
    }
    
    func removeUsabilitySubview() {
        if usabilityView != nil {
            usabilityView!.removeFromSuperview()
            usabilityView = nil
            bunchButton.setAlphaAnimated(1)
        }
    }
    
    //
    // FILTER TABLEVIEW
    //
    

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var filterBarButton: UIBarButtonItem!
    
    @IBAction func didTapMap(sender: UITapGestureRecognizer) {
        let point = sender.locationInView(mapView)
        let tappedView = mapView.hitTest(point, withEvent: nil)
        if let _ = tappedView as? MKAnnotationView { return }
        if !navigationController!.navigationBarHidden {
            hideUI()
        } else {
            showUI()
        }
    }
    
    @IBAction func toggleFilters(sender: AnyObject) {
        if !filterVC.visible {
            showFilterViewController()
        } else {
            hideFilterViewController()
        }
    }
    
    func showFilterViewController() {
        filterVC.show()
//        filterBarButton.image = BNCImage.mapPinMenuFill
    }
    
    func hideFilterViewController() {
        filterVC.hide()
//        filterBarButton.image = BNCImage.mapPinMenu
    }
    
    func askForPushPermissionIfNeeded() {
        if !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
            let defaults = NSUserDefaults.standardUserDefaults()
            let pushAsked = defaults.boolForKey("pushAlertAsked") as Bool?
            if pushAsked == nil || pushAsked == false {
                let alert = UIAlertController(title: "Notifications", message: "We'd like to send you a buzz when someone checks in to your bunch", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                    defaults.setBool(true, forKey: "pushAlertAsked")
                    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
                    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                    UIApplication.sharedApplication().registerForRemoteNotifications()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
}
