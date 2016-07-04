//
//  BunchFilter.swift
//  Bunch
//
//  Created by David Woodruff on 2015-10-22.
//  Copyright © 2015 Jukeboy. All rights reserved.
//
//  Class for filter settings of an instance of Bunch
//
//

import Foundation
import Parse

// to incorporate new filter property:
// 1. add to enum
// 2. add to filter order
// 2a. add to essential filters
// 3. add filter procedure to "bunchPassesFilter"

enum BNCFilterProperty {
    case Full
    case Blocked
//    case Distance
    case Present
    case Future
}

protocol BNCFilterDelegate {
    func addFilterProperty(filter: BNCFilterProperty)
    func removeFilterProperty(filter: BNCFilterProperty)
    func getActiveFilters() -> Set<BNCFilterProperty>
}

class BNCFilter {
    
    var manager: BNCManager
    let essentialFilters: Set<BNCFilterProperty> = [.Full, .Blocked] // , .Distance]
    var activeFilters: Set<BNCFilterProperty>
    
    var myChannels: [String]
    var checkedIn: Int
    
    var filterOrder = [BNCFilterProperty.Full:0, BNCFilterProperty.Present:1,
        BNCFilterProperty.Future:2, BNCFilterProperty.Blocked:3]

//    var filterOrder = [BNCFilterProperty.Distance:0, BNCFilterProperty.Full:1, BNCFilterProperty.Present:2,
//        BNCFilterProperty.Future:3, BNCFilterProperty.Blocked:4]
    
    func sortFcn(f1: BNCFilterProperty, _ f2: BNCFilterProperty) -> Bool {
        return filterOrder[f1] > filterOrder[f2]
    }
    
    init(manager: BNCManager) {
        checkedIn = 0 // 0 is any size (default)
        myChannels = []
        activeFilters = essentialFilters
        self.manager = manager
    }
    
    //
    //  Misc. Public Functions
    //
    
    func getActiveFilters() -> Set<BNCFilterProperty> {
        return activeFilters
    }
    
    func addProperty(filter: BNCFilterProperty) {
        activeFilters.insert(filter)
    }
    
    func removeProperty(filter: BNCFilterProperty) {
        activeFilters.remove(filter)
    }
    
    
    //
    //  LETS FILTER BUNCHES
    //
    
    
    
    // Step 1: Pass Bunches Through Filter
    // sorcery speed
    func filterBunches(set: Set<BNCBunch>) {
        guard !set.isEmpty else { manager.handleFiltrate(set); return }
        var filteredBunches = Set<BNCBunch>()
        let qos = QOS_CLASS_BACKGROUND
        let queue = dispatch_get_global_queue(qos, 0)
        let setCount = set.count
        var count = 0
        
        for bunch in set {
            dispatch_async(queue) {
                let bunchPassed = self.bunchPassesFilters(bunch)
                dispatch_async(dispatch_get_main_queue()) {
                    if bunchPassed {
                        // Step 2: Bunch filtered, yay
                        self.manager.handleFiltrate(bunch)
                        filteredBunches.insert(bunch)
                    }
                    count += 1; if count == setCount { //doesnt werk
                        // Step 3: Set Filtered
                        self.manager.handleFiltrate(filteredBunches)
                    }
                }
            }
        }
        

    }

    
    // Extra: "Quick Check" Function
    // instant speed
    func essentialFilterTest(bunch: BNCBunch) -> Bool {
        do { try bunch.fetch() }
        catch { return false }
        for filter in essentialFilters.sort(sortFcn) {
            switch filter {
            case .Full:
                if !bunchPassesFilter(bunch, filter: .Full) {
                    return false
                }
            case .Blocked:
                if !bunchPassesFilter(bunch, filter: .Blocked) {
                    return false
                }
//            case .Distance:
//                if !bunchPassesFilter(bunch, filter: .Distance) {
//                    return false
//                }
            default: break
            }
        }
        return true
    }
    

    //
    //  FILTER PRIVATE
    //
    
    private func bunchPassesFilters(bunch: BNCBunch) -> Bool {
        for filter in self.activeFilters.sort(sortFcn) {
            guard bunchPassesFilter(bunch, filter: filter) else { return false }
        }
        return true
    }
    
    func bunchPassesFilter(bunch: BNCBunch, filter: BNCFilterProperty) -> Bool {
        // auto pass if bunch is already active
        if manager.activeBunch != nil {
            guard bunch != manager.activeBunch! else { return true }
        }
        
        //can't filter something not online
        guard bunch.online == true else { return true }
        
        switch filter {
            
        case .Full:
            if bunch.checkedIn?.count >= bunch.size && bunch.size != 0 { return false }
            return true
            
        case .Present:
            if bunch.type == "present" { return false }
            return true
            
        case .Future :
            if bunch.type == "future" { return false }
            return true
            
        case .Blocked:
            let user = PFUser.currentUser()!
            //step 1: find if the searchers blocked list has a user checkedIn
            let blockedUsers = user.objectForKey("blocked") as? [PFUser]
            if blockedUsers != nil {
                for bUser in blockedUsers! {
                    for cUser in bunch.checkedIn! { if bUser == cUser {
                        return false } }
                }
            }
            //step 2: find if a user checkedIn has the searcher on their blockedList
            for cUser in bunch.checkedIn! {
                do {
                    try cUser.fetch()
                } catch {
                    print(error)
                    return false
                }
                let cBlockedUsers = cUser.valueForKey("blocked") as? [PFUser]
                if cBlockedUsers != nil {
                    for bUser in cBlockedUsers! { if bUser == user {
                        return false } }
                }
            }
            return true
            
//        case .Distance:
//            guard manager.userLocation != nil else { return false }
//            let userLocation = manager.userLocation!
//            let bunchLocation = CLLocation.init(latitude: bunch.coordinate!.latitude,
//                longitude: bunch.coordinate!.longitude)
//            return DistanceCalculator().distanceBetweenCoordinatesAppropriate(userLocation, locB: bunchLocation)
        }
    }
}