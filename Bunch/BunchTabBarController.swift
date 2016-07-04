//
//  CreateTabBarController.swift
//  Bunch
//
//  Created by David Woodruff on 2015-08-26.
//  Copyright (c) 2015 Jukeboy. All rights reserved.
//

import UIKit
import Parse
import Spring

class BunchTabBarController: UITabBarController {
    
    @IBInspectable var normalTint: UIColor = UIColor.clearColor() {
        didSet {
            UITabBar.appearance().tintColor = normalTint
            UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: normalTint], forState: UIControlState.Normal)
        }
    }
    
    @IBInspectable var selectedTint: UIColor = UIColor.clearColor() {
        didSet {
            UITabBar.appearance().tintColor = selectedTint
            UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: selectedTint], forState:UIControlState.Selected)
        }
    }
    
    var parent: BunchViewController!
    
    var bunch: BNCBunch! {
        didSet {
            initTabBar()
        }
    }
    
    var tabs = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().barStyle = UIBarStyle.Default
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    func initTabBar() {
        var initTabs = [String]()
        
        switch bunch.type! {
            case "present":
            switch bunch.relation {
            case .Viewer: initTabs = [StoryID.SummaryTab, StoryID.ReportTab]
            case .Attendee: initTabs = [StoryID.SummaryTab]
            case .Host: initTabs = [StoryID.SummaryTab, StoryID.PeopleTab, StoryID.PhotoTab, StoryID.FinishTab]
            case .Creator: initTabs = [StoryID.BlurbTab, StoryID.PhotoTab]
            }
            case "future":
            switch bunch.relation {
            case .Viewer: initTabs = [StoryID.SummaryTab, StoryID.ReportTab]
            case .Attendee: initTabs = [StoryID.SummaryTab]
            case .Host: initTabs = [StoryID.SummaryTab, StoryID.PeopleTab, StoryID.PhotoTab, StoryID.FinishTab]
            case .Creator: initTabs = [StoryID.BlurbTab, StoryID.TimeTab, StoryID.PhotoTab]
            }
            default: break
        }
        addTabsToTabBar(initTabs)
        self.selectedIndex = 0
    }
    
    func deinitTabBar() {
        self.viewControllers = nil
        self.bunch = nil
    }
    
    func addTabsToTabBar(initTabs: [String]) {
        for tab in initTabs {
            var newTab: UIViewController!
            var icon: UITabBarItem!
            switch tab {
                
            // creator
                                
            case StoryID.TimeTab:
                newTab = storyboard!.instantiateViewControllerWithIdentifier(tab) as? TimeTabViewController
                icon = UITabBarItem(title: "Time", image: BNCImage.timeTab, selectedImage: BNCImage.timeTabFill)
                
            case StoryID.BlurbTab:
                newTab = storyboard!.instantiateViewControllerWithIdentifier(tab) as? BlurbTabViewController
                icon = UITabBarItem(title: "Blurb", image: BNCImage.blurbTab, selectedImage: BNCImage.blurbTabFill)
                if let dvc = newTab as? BlurbTabViewController {
                    dvc.bunch = bunch
                }
                
            case StoryID.PhotoTab:
                newTab = storyboard!.instantiateViewControllerWithIdentifier(tab) as? PhotoTabViewController
                icon = UITabBarItem(title: "Photo", image: BNCImage.photoTab, selectedImage: BNCImage.photoTabFill)
                if let dvc = newTab as? PhotoTabViewController {
                    dvc.bunch = bunch
                }
                
            // Attendee/Host/Viewer
                
            case StoryID.SummaryTab:
                newTab = storyboard!.instantiateViewControllerWithIdentifier(tab) as? SummaryTabViewController
                if let dvc = newTab as? SummaryTabViewController {
                    dvc.bunch = bunch
                }
                icon = UITabBarItem(title: "Bunch", image: BNCImage.mapPin, selectedImage: BNCImage.mapPinFill)
                
            case StoryID.PeopleTab:
                newTab = storyboard!.instantiateViewControllerWithIdentifier(tab) as? PeopleTabViewController
                icon = UITabBarItem(title: "People", image: BNCImage.peopleTab, selectedImage: BNCImage.peopleTabFill)
                if let dvc = newTab as? PeopleTabViewController {
                    dvc.bunch = bunch
                }
                
            case StoryID.FinishTab:
                newTab = storyboard!.instantiateViewControllerWithIdentifier(tab) as? FinishTabViewController
                icon = UITabBarItem(title: "Finish", image: BNCImage.finishTab, selectedImage: BNCImage.finishTabFill)
                if let dvc = newTab as? FinishTabViewController {
                    dvc.bunch = bunch
                    dvc.parent = self
                }
                
            case StoryID.ReportTab:
                newTab = storyboard!.instantiateViewControllerWithIdentifier(tab) as? ReportTabViewController
                icon = UITabBarItem(title: "Report", image: BNCImage.reportTab, selectedImage: BNCImage.reportTabFill)
                if let dvc = newTab as? ReportTabViewController {
                    dvc.bunch = bunch
                }
                
            default: break
            }
            newTab!.tabBarItem = icon
            if self.viewControllers?.isEmpty == false { self.viewControllers?.append(newTab) }
            else { self.viewControllers = [newTab] }
        }
    }
    
    func updateToCheckedIn() {
        self.viewControllers?.removeLast()
//        if let svc = self.selectedViewController as? FutureTabViewController {
//            svc.temporaryPlusOne()
//        } else if let svc = self.selectedViewController as? PresentTabViewController {
//            svc.temporaryPlusOne()
//        }
    }
    
    func updateToCheckedOut() {
        let initTab = [StoryID.ReportTab]
        addTabsToTabBar(initTab)
    }
    
    func checkBunchValidity() {
        tabs = (self.viewControllers)!
        for tab in tabs {
            if let tabForValidating = tab as? BunchCreationTab {
                if tabForValidating.tabIsValid == false {
                    if let _ = parent.utilityView as? CreateValidView {
                        parent.loadUtility(.CreateInvalid)
                    }
                    return
                }
            }
        }
        
        if let _ = parent.utilityView as? CreateInvalidView {
            parent.loadUtility(.CreateValid)
        }
    }
    
    func checkBunchPartialValidity() -> Bool {
        var validCount = 0
        tabs = (self.viewControllers )!
        for tab in tabs {
            if let tabForValidating = tab as? BunchCreationTab {
                if tabForValidating.tabIsValid == true {
                    validCount += 1
                }
            }
        }
        if validCount > 1 { return true }
        else { return false }
    }
    
    func getInfoFromTabs() -> [AnyObject?] {
        var tabInformation = [AnyObject?]()
        for tab in tabs {
            if let farm = tab as? BunchCreationTab {
                tabInformation.append(farm.getInfo())
            }
        }
        return tabInformation
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        parent.resignFirstResponder()
    }
}
