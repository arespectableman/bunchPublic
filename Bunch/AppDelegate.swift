//
//  AppDelegate.swift
//  Bunch
//
//  Created by David Woodruff on 2015-08-11.
//  Copyright (c) 2015 Jukeboy. All rights reserved.
//

import UIKit
import Parse
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.enableLocalDatastore()
        Parse.setApplicationId("IDHere", clientKey: "KeyHere")
        PFUser.logOutInBackground()
        
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GIDSignIn.sharedInstance().delegate = self
    
        UINavigationBar.appearance().tintColor = BNCColor.blue
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: BNCColor.blue,  NSFontAttributeName: UIFont(name: "WisdomScript-Regular", size: 20)!]
        
        

        
        return true
    }
    
    func application(application: UIApplication,
        openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {

        return GIDSignIn.sharedInstance().handleURL(url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NSNotificationCenter.defaultCenter().postNotificationName(BNCNotification.backgroundNotification, object: self)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if let currentInstallation = PFInstallation.currentInstallation() as? PFInstallation {
            currentInstallation.badge = 0
            currentInstallation.saveInBackground()
        }
        NSNotificationCenter.defaultCenter().postNotificationName(BNCNotification.foregroundNotification, object: self)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Siren.sharedInstance.checkVersion(.Daily)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser GIDuser: GIDGoogleUser!,
        withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let accessToken = GIDuser.authentication.accessToken
            
            let email = GIDuser.profile.email
            PFCloud.callFunctionInBackground("accessGoogleUser", withParameters: ["email" : email, "code" : accessToken]) {
                (response: AnyObject?, error: NSError?) -> Void in
                if response != nil {
                    PFUser.becomeInBackground(response as! String) {
                        (user: PFUser?, error: NSError?) -> Void in
                        if user != nil {
                            // Access the storyboard and fetch an instance of the view controller
                            
                            if !self.userIsValid(user!) { return }
                            
                            if user!["deleted"] as? Bool == true {
                                user!["deleted"] = false
                                do {
                                    try user!.save()
                                } catch {
                                    print(error)
                                }
                            }
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController: HomeViewController = storyboard.instantiateViewControllerWithIdentifier("Home") as! HomeViewController
                            // Then push that view controller onto the navigation stack
                            let rootViewController = self.window!.rootViewController as! UINavigationController
                            rootViewController.pushViewController(viewController, animated: true)
                            SwiftOverlays.removeAllBlockingOverlays()
                        } else {
                            print(error)
                            let alert = EasyAlert().alertWithTitleAndMessage(BNCString.AlertTitle, message: BNCString.LoginAlertMessage)
                            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                            GIDSignIn.sharedInstance().signOut()
                            PFUser.logOutInBackground()
                            SwiftOverlays.removeAllBlockingOverlays()
                        }
                    }
                } else {
                    print(error)
                    let alert = EasyAlert().alertWithTitleAndMessage(BNCString.AlertTitle, message: BNCString.LoginAlertMessage)
                    self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                    GIDSignIn.sharedInstance().signOut()
                    PFUser.logOutInBackground()
                    SwiftOverlays.removeAllBlockingOverlays()
                }
            }
        } else {
            //remove "logging in" overlay
            if let nvc = self.window?.rootViewController as? UINavigationController {
                for vc in nvc.viewControllers {
                    if let lvc = vc as? LoginViewController {
                        lvc.removeAllOverlays()
                    }
                }
            }
            GIDSignIn.sharedInstance().signOut()
            PFUser.logOutInBackground()
            SwiftOverlays.removeAllBlockingOverlays()
        }
    }

    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
        withError error: NSError!) {
            // Perform any operations when the user disconnects from app here.
            // ...
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation["user"] = PFUser.currentUser()
        currentInstallation.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("registered for remote notifications")
            } else {
                print("failed to register: \(error)")
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
    }
    
    func userIsValid(user: PFUser) -> Bool {
        do {
            try user.fetchIfNeeded()
        } catch {
            print(error)
        }
        if user["banned"] as? Bool == true {
            let alert = EasyAlert().alertWithTitleAndMessage("Account Banned", message: "This account has been banned. Please contact us for further information.")
            SwiftOverlays.removeAllBlockingOverlays()
            GIDSignIn.sharedInstance().signOut()
            PFUser.logOut()
            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            return false
        }
        
        let email = user["email"] as? String
        if email == "bunchtest1@gmail.com" ||
            email == "bunchtest2@gmail.com" ||
            email == "bunchtest3@gmail.com" ||
            email == "bunchtest4@gmail.com" ||
            email == "bunchtest5@gmail.com" ||
            email == "davepwoodruff@gmail.com"
        {
            return true
        } else if email!.endsWith("@ualberta.ca") {
            return true
        }
        let alert = EasyAlert().alertWithTitleAndMessage("Invalid Email", message: "Please use an @ualberta.ca Google account.")
        SwiftOverlays.removeAllBlockingOverlays()
        GIDSignIn.sharedInstance().signOut()
        PFUser.logOut()
        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        return false

    }
}

