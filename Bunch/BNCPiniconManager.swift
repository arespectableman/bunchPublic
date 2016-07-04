//
//  BNCPiniconManager.swift
//  Bunch
//
//  Created by David Woodruff on 2015-11-24.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation
import Parse

class BNCPiniconManager {
    
    var manager: BNCManager
    var createablePiniconNames: [String] =  BNCIcon.defaultPinicons
    var viewablePinicons = [BNCPinicon]()
    
    init(manager: BNCManager) {
        self.manager = manager
        //create viewable list
        for name in BNCIcon.systemPinicons {
            let pinicon = BNCPinicon(piniconManager: self, name: name)
            viewablePinicons.append(pinicon)
        }
        getCustomPiniconsFromParse()
        
    }
    
    func getPiniconForIconNameWithPin(name name: String?, pin: UIImage) -> UIImage {
        guard name != nil else {
            return createPiniconFromPinAndIcon(pin, icon: nil)
        }
        for pinicon in viewablePinicons {
            if pinicon.name == name! {
                let icon = pinicon.getIcon()
                return createPiniconFromPinAndIcon(pin, icon: icon)
            }
        }
        viewablePinicons.append(BNCPinicon(piniconManager: self, name: name!))
        return createPiniconFromPinAndIcon(pin, icon: nil)
    }
    
    func getFullPiniconForIconNameWithPin(name name: String?, pin: UIImage) -> UIImage {
        guard name != nil else {
            return createPiniconFromPinAndIcon(pin, icon: nil)
        }
        for pinicon in viewablePinicons {
            if pinicon.name == name! {
                let icon = pinicon.getIcon(full: true)
                return createFullPiniconFromPinAndIcon(pin, icon: icon)
            }
        }
        viewablePinicons.append(BNCPinicon(piniconManager: self, name: name!))
        return createPiniconFromPinAndIcon(pin, icon: nil)
    }
    
    
    
    func getPiniconFromName(name: String) -> UIImage {
        for pinicon in viewablePinicons {
            if pinicon.name == name {
                return pinicon.getIcon()!
            }
        }
        return UIImage()
    }
    
    
    private func addCreateablePiniconWithName(name: String) {
        createablePiniconNames.append(name)
        let pinicon = BNCPinicon(piniconManager: self, name: name)
        viewablePinicons.append(pinicon)
    }
    
    
    private func getCustomPiniconsFromParse() {
        let user = PFUser.currentUser()!
        if let piniconNamesToAdd = user.valueForKey("piniconPermissions") as? [String] {
            for piniconName in piniconNamesToAdd {
                addCreateablePiniconWithName(piniconName)
            }
        }
    }
    
    
    // create dem icons
    
    private func createPiniconFromPinAndIcon(pin: UIImage, icon: UIImage?) -> UIImage {
        
        let iconOriginX: CGFloat = 12.5
        let iconOriginY: CGFloat = 13.5
        
        let size = CGSizeMake(pin.size.width, pin.size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        
        let pinRect = CGRectMake(0, 0, size.width, size.height)
        pin.drawInRect(pinRect, blendMode: CGBlendMode.Normal, alpha: 1.0)
        
        guard icon != nil else {
            let pinicon =  UIGraphicsGetImageFromCurrentImageContext()
            return pinicon
        }
        
        let iconRect = CGRectMake(iconOriginX, iconOriginY, icon!.size.width, icon!.size.width)
        icon!.drawInRect(iconRect, blendMode: CGBlendMode.Normal, alpha: 1.0)
        
        let pinicon =  UIGraphicsGetImageFromCurrentImageContext()
        return pinicon
    }
    
    private func createFullPiniconFromPinAndIcon(pin: UIImage, icon: UIImage?) -> UIImage {
        
        // the magic numbers
        let iconScrunch: CGFloat = 0.5
        let iconOriginX: CGFloat = 75
        let iconOriginY: CGFloat = 85
        
        let size = CGSizeMake(pin.size.width, pin.size.height)
        
        UIGraphicsBeginImageContext(size)
        
        let pinRect = CGRectMake(0, 0, size.width, size.height)
        pin.drawInRect(pinRect, blendMode: CGBlendMode.Normal, alpha: 1.0)
        
        guard icon != nil else {
            let pinicon =  UIGraphicsGetImageFromCurrentImageContext()
            return pinicon
        }
    
        let iconRect = CGRectMake(iconOriginX, iconOriginY, icon!.size.width*iconScrunch, icon!.size.width*iconScrunch)
        icon!.drawInRect(iconRect, blendMode: CGBlendMode.Normal, alpha: 1.0)
        
        let pinicon =  UIGraphicsGetImageFromCurrentImageContext()
        return pinicon
    }
    
    
    
    
    
    //    FOR DELEVOPER USE ONLY
//    func addPiniconToParse() {
//        let img1x = UIImage(named: "star1x.png")!
//        let img2x = UIImage(named: "star2x.png")!
//        let img3x = UIImage(named: "star3x.png")!
//        let imgFull = UIImage(named: "starFull.png")!
//        
//        let imageData1x = UIImagePNGRepresentation(img1x)!
//        let imageData2x = UIImagePNGRepresentation(img2x)!
//        let imageData3x = UIImagePNGRepresentation(img3x)!
//        let imageDataFull = UIImagePNGRepresentation(imgFull)!
//        
//        let imageFile1x = PFFile(name:"pinicon1x", data:imageData1x)
//        let imageFile2x = PFFile(name:"pinicon2x", data:imageData2x)
//        let imageFile3x = PFFile(name:"pinicon3x", data:imageData3x)
//        let imageFileFull = PFFile(name:"piniconFull", data:imageDataFull)
//        
//        let pinicon = PFObject(className: "Pinicon")
//        
//        pinicon["name"] = "star"
//        pinicon["icon1x"] = imageFile1x
//        pinicon["icon2x"] = imageFile2x
//        pinicon["icon3x"] = imageFile3x
//        pinicon["iconFull"] = imageFileFull
//        
//        pinicon.saveInBackground()
//    }
    
}




