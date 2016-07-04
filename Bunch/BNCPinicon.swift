//
//  BNCPinicon.swift
//  Bunch
//
//  Created by David Woodruff on 2015-11-20.
//  Copyright © 2015 Jukeboy. All rights reserved.
//

import Foundation
import Parse

class BNCPinicon {
    
    var piniconManager: BNCPiniconManager
    
    var name: String
    var fromParse: Bool
    
    var icon1x: UIImage?
    var icon2x: UIImage?
    var icon3x: UIImage?
    var iconFull: UIImage?
    
    init(piniconManager: BNCPiniconManager, name: String) {
        self.piniconManager = piniconManager
        self.name = name
        if BNCIcon.systemPinicons.contains(self.name) {
            fromParse = false
        } else {
            fromParse = true
            let qos = QOS_CLASS_BACKGROUND
            let queue = dispatch_get_global_queue(qos, 0)
            dispatch_async(queue) {
                self.loadPiniconFromParse()
                dispatch_async(dispatch_get_main_queue()) {
                    self.registerAsNewlyLoaded()
                }
            }
        }
    }

    func getIcon(full fullRes: Bool = false) -> UIImage? {
        
        if fullRes {
            if !fromParse{
                //get from system
                switch name {
                case "active": return BNCIcon.activeFull!
                case "book": return BNCIcon.bookFull!
                case "coffee": return BNCIcon.coffeeFull!
                case "food": return BNCIcon.foodFull!
                case "music": return BNCIcon.musicFull!
                case "pride": return BNCIcon.prideFull!
                case "look": return BNCIcon.lookFull!
                case "game": return BNCIcon.gameFull!
                case "drama": return BNCIcon.dramaFull!
                case "brain": return BNCIcon.brainFull!
                case "power": return BNCIcon.powerFull!
                default: break
                }
            } else {
                // get "from parse"
                return iconFull
            }
        } else {
            //not full res
            if !fromParse{
                //get from system
                switch name {
                case "active": return BNCIcon.active!
                case "book": return BNCIcon.book!
                case "coffee": return BNCIcon.coffee!
                case "food": return BNCIcon.food!
                case "music": return BNCIcon.music!
                case "pride": return BNCIcon.pride!
                case "look": return BNCIcon.look!
                case "game": return BNCIcon.game!
                case "drama": return BNCIcon.drama!
                case "brain": return BNCIcon.brain!
                case "power": return BNCIcon.power!
                default: break
                }
            } else {
                //get correct icon "from parse"
                switch UIScreen.mainScreen().scale {
                case 1: return icon1x
                case 2: return icon2x
                case 3: return icon3x
                default: return icon1x
                }
            }
        }
        return nil
    }
    
    private func loadPiniconFromParse() {
        
        var pinicon: PFObject
        let query = PFQuery(className: "Pinicon")
        query.whereKey("name", equalTo: self.name)
        
        do {
            // find pinicon
            try pinicon = query.getFirstObject()
            
            // save 1x
            if let iconFile1x = pinicon["icon1x"] as? PFFile {
                do {
                    let imageData = try iconFile1x.getData()
                    icon1x = UIImage(data: imageData)
                    let cgImage = icon1x!.CGImage
                    icon1x = UIImage(CGImage: cgImage!, scale: 1, orientation: UIImageOrientation.Up)
                } catch {
                    print(error)
                }
            }
            
            // save 2x
            if let iconFile2x = pinicon["icon2x"] as? PFFile {
                do {
                    let imageData = try iconFile2x.getData()
                    icon2x = UIImage(data: imageData)
                    let cgImage = icon2x!.CGImage
                    icon2x = UIImage(CGImage: cgImage!, scale: 2, orientation: UIImageOrientation.Up)
                } catch {
                    print(error)
                }
            }
            
            // save 3x
            if let iconFile3x = pinicon["icon3x"] as? PFFile {
                do {
                    let imageData = try iconFile3x.getData()
                    icon3x = UIImage(data: imageData)
                    let cgImage = icon3x!.CGImage
                    icon3x = UIImage(CGImage: cgImage!, scale: 3, orientation: UIImageOrientation.Up)
                } catch {
                    print(error)
                }
            }
            
            // save full
            if let iconFileFull = pinicon["iconFull"] as? PFFile {
                do {
                    let imageData = try iconFileFull.getData()
                    iconFull = UIImage(data: imageData)
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
    
    private func registerAsNewlyLoaded() {
        //update annotations on map
        for annotation in piniconManager.manager.mapView.annotations {
            if let bunchAn = annotation as? BNCAnnotation {
                if bunchAn.bunch.icon == name {
                    //triggers annotationView reset
                    bunchAn.bunch.icon = name
                }
            }
        }
        piniconManager.manager.homeVC.bunchButton.determineState()
    }
}