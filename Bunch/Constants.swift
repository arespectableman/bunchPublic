//
//  Constants.swift
//  Bunch
//
//  Created by David Woodruff on 2015-08-12.
//  Copyright (c) 2015 Jukeboy. All rights reserved.
//

import Foundation
import UIKit

struct BNCType {
    static let Future = "future"
    static let Present = "present"
}

struct Channels {
    static let tablespace = "tablespace"
    static let events = "event"
}

struct BNCImage {
    
    //tabbar
    static let blurbTab = UIImage(named: "blurbTab")
    static let blurbTabFill = UIImage(named: "blurbTabFill")

    static let finishTab = UIImage(named: "finishTab")
    static let finishTabFill = UIImage(named: "finishTabFill")
    
    static let photoTab = UIImage(named: "photoTab")
    static let photoTabFill = UIImage(named: "photoTabFill")
    
    static let reportTab = UIImage(named: "reportTab")
    static let reportTabFill = UIImage(named: "reportTabFill")
    
    static let timeTab = UIImage(named: "timeTab")
    static let timeTabFill = UIImage(named: "timeTabFill")
    
    static let peopleTab = UIImage(named: "peopleTab")
    static let peopleTabFill = UIImage(named: "peopleTabFill")
    
    static let tabValid = UIImage(named: "tabValid")
    static let tabValidFill = UIImage(named: "tabValidFill")
    
    static let mapPin = UIImage(named: "mapPin")
    static let mapPinFill = UIImage(named: "mapPinFill")
    
    static let mapPinMenu = UIImage(named: "mapPinMenu")
    static let mapPinMenuFill = UIImage(named: "mapPinMenuFill")
    
    
    //pins
    static let greenPinOnMap = UIImage(named: "greenPinOnMap")
    static let orangePinOnMap = UIImage(named: "orangePinOnMap")
    static let orangePin = UIImage(named: "orangePin")
    static let greenPin = UIImage(named: "greenPin")
    static let greenPinActive = UIImage(named: "greenPinActive")
    static let greenPinCreate = UIImage(named: "greenPinCreate")
    static let orangePinActive = UIImage(named: "orangePinActive")
    static let orangePinCreate = UIImage(named: "orangePinCreate")
    
    static let pinCreate = UIImage(named: "pinCreate")
}

struct BNCIcon {
    static let defaultPinicons: [String] = ["food","coffee","drama","active","look","book","music","game","brain","pride"] //order it appears when creating
    
    static let systemPinicons: [String] = ["food","book","music","coffee","pride",
        "active","look","drama","game","brain","power"] //order doesn't matter
    
    static let active = UIImage(named: "iconActive")
    static let book = UIImage(named: "iconBook")
    static let coffee = UIImage(named: "iconCoffee")
    static let food = UIImage(named: "iconFood")
    static let music = UIImage(named: "iconMusic")
    static let pride = UIImage(named: "iconPride")
    static let look = UIImage(named: "iconLook")
    static let game = UIImage(named: "iconGame")
    static let drama = UIImage(named: "iconDrama")
    static let brain = UIImage(named: "iconBrain")
    //non-default
    static let power = UIImage(named: "iconPower")
    
    static let activeFull = UIImage(named: "iconActiveFull")
    static let bookFull = UIImage(named: "iconBookFull")
    static let coffeeFull = UIImage(named: "iconCoffeeFull")
    static let foodFull = UIImage(named: "iconFoodFull")
    static let musicFull = UIImage(named: "iconMusicFull")
    static let prideFull = UIImage(named: "iconPrideFull")
    static let lookFull = UIImage(named: "iconLookFull")
    static let gameFull = UIImage(named: "iconGameFull")
    static let dramaFull = UIImage(named: "iconDramaFull")
    static let brainFull = UIImage(named: "iconBrainFull")
    //non-default
    static let powerFull = UIImage(named: "iconPowerFull")
    
}

struct BNCBunchType {
    static let present = "present"
    static let future = "future"
}

struct BNCColor {
    static let lightBlue = UIColor(rgba: "#96B2F8")
    static let blue = UIColor(rgba: "#3F6CDC")
    static let darkBlue = UIColor(rgba: "#032D95")
    
    static let lightGreen = UIColor(rgba: "#88EB83")
    static let green = UIColor(rgba: "#63DE5D") 
    static let darkGreen = UIColor(rgba: "#45D03E")
    
    static let lightOrange = UIColor(rgba: "#FFC18F")
    static let orange = UIColor(rgba: "#FFAE6B")
    static let darkOrange = UIColor(rgba: "#FF9D4C")
    
//    static let transparentGreen = UIColor(rgba: "#38EB2FB3") //70
//    static let transparentOrange = UIColor(rgba: "#FF8F33B3") //70
//    static let transparentBlue = UIColor(rgba: "#3F6CDCB3")
    
    
    static let red = UIColor(hex: "#FF5C58")
    
}

struct BNCNotification {
    static let backgroundNotification = "jukeboy.backgroundNotification"
    static let foregroundNotification = "jukeboy.foregroundNotification"
    static let locationUpdated = "jukeboy.locationUpdated"
}

struct Segue {
    static let HomeToBunch = "HomeToBunch"
    static let ContainerToTabBar = "ShowTabBar"
    static let LoginToHome = "ShowHome"
    static let BunchToHome = "UnwindBunchToMap"
    static let HomeToWelcome = "ModalWelcome"
    static let HomeToLocationNeeded = "ModalLocationNeeded"
    static let WelcomeToHome = "UnwindFromWelcome"
    static let LocationNeededToHome = "FromLocationNeeded"
    static let TabToImageDetail = "ShowImageDetail"
    static let HomeToLogin = "UnwindToLogin"
    static let HomeToUser = "ModalUser"
    static let MapToInternet = "ModalInternet"
    static let HomeToFilter = "HomeToFilter"
    static let EmbededToFilter = "EmbededToFilter"
    static let HomeToEmbeded = "HomeToEmbeded"
    static let ModalCustomPinicons = "ModalCustomPinicons"
}

struct BNCNum { //minus1 bcs
    static let MapBunchOffset: CGFloat = 11/32 // bigger num = higher the bunchVC is from the annotation
    static let MapWidthFraction: CGFloat = 13/16 //dont think i use this
    static let MapHeightFraction: CGFloat = 1/2
    
    static let keyboardFrameOffset: CGFloat = 50
    
    //static let pinOnMapScrunch: CGFloat = 0.4 // smaller num = smaller pin
    
    static let bunchSizeMax = 8
    
    static let futureBlurbTextMax = 140
    static let futureBlurbTextMin = 6
    
    static let presentBlurbTextMax = 200
    static let presentBlurbTextMin = 6
}

struct BNCString {
    static let blurbPlaceholder = "Describe your purpose, space, or self. Everything everyone should know about your bunch."
    
    static let AlertTitle = "Whoopsie"
    static let LoginAlertMessage = "Something went wrong with the login. Please try again"
    
    
    static let CreateWait = "Creating bunch..."
    static let RenewWait = "Renewing bunch..."
    static let CheckInWait = "Checking in..."
    static let CheckOutWait = "Checking out..."
    static let SaveWait = "Saving bunch..."
    
    static let WarningTitle = "Parallel Universes Not Supported"
    static let WarningMessage =  "You can only be active in one bunch at a time"
    
    static let NavBarDefaultTitle = "ualberta"
    
    static let Report = "Report bunches that are fake, offensive, graphic, promoting of harm and/or capitalism."
    
    static let PrivacyPolicyURL = "http://bunch.social/privacy"
    static let TermsOfUseURL = "http://bunch.social/terms"
    static let ContactURL = "http://bunch.social/contact"
}

struct BNCErrorMessage {
    static let BunchNoLongerAvailable = "That bunch is no longer available"
    static let ActiveBunchNoLongerAvailable = "Your active bunch is no longer available"
}

struct StoryID {
    static let NameTab = "NameTab"
    static let TimeTab = "TimeTab"
    static let BlurbTab = "BlurbTab"
    static let PhotoTab = "PhotoTab"
    static let FinishTab = "FinishTab"
    static let PeopleTab = "PeopleTab"
    static let SummaryTab = "SummaryTab"
    static let ReportTab = "ReportTab"
    
    static let FilterVC = "FilterVC"
}



