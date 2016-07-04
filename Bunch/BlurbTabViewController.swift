//
//  BlurbTabViewController.swift
//  Bunch
//
//  Created by David Woodruff on 2015-08-26.
//  Copyright (c) 2015 Jukeboy. All rights reserved.
//

import UIKit
import Spring

class BlurbTabViewController: UIViewController, UITextViewDelegate, BunchCreationTab, UITabBarControllerDelegate {
    
    @IBOutlet weak var textView: DesignableTextView! { didSet { textView.delegate = self } }
    
    @IBOutlet weak var charactersLeftLabel: UILabel!
    
    var bunch: BNCBunch!
    var minText: Int!
    var maxText: Int!
    
    var tabIsValid: Bool = false {
        didSet {
            if tabIsValid {
                // 1 Alter the titleTabBar text
                var tabBarTitle: String!
                if textView.text.characters.count <= 10 { tabBarTitle = textView.text}
                else { tabBarTitle = "\(textView.text[0...10])..." }
                // 2 Set image
                self.tabBarItem = UITabBarItem(title: tabBarTitle, image: BNCImage.tabValid, selectedImage: BNCImage.tabValidFill)
            } else {
                self.tabBarItem = UITabBarItem(title: "Blurb", image: BNCImage.blurbTab, selectedImage: BNCImage.blurbTabFill)
                tabBarController?.selectedIndex = 0 //for weird VC-not-selected bug
            }
            if let pvc = self.tabBarController as? BunchTabBarController {
                pvc.checkBunchValidity()
            }
        }
    }
    
    func getInfo() -> AnyObject? {
        return textView.text
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //tabIsValid = false
        
        switch bunch.type! {
            case "present":
            minText = BNCNum.presentBlurbTextMin
            maxText = BNCNum.presentBlurbTextMax
            case "future":
            minText = BNCNum.futureBlurbTextMin
            maxText = BNCNum.futureBlurbTextMax
            default: break
        }
        
        tabBarController?.delegate = self
        
        textView.text = BNCString.blurbPlaceholder
        textView.textColor = UIColor.lightGrayColor()
        
        if textView.textColor != UIColor.lightGrayColor() {
            charactersLeftLabel.text = "\(maxText - textView.text.characters.count)"
        } else { charactersLeftLabel.text = "\(maxText)" }
        
        textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            textView.text = BNCString.blurbPlaceholder
            textView.textColor = UIColor.lightGrayColor()
            
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if textView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        
        let oldString = textView.text as NSString
        let newString = oldString.stringByReplacingCharactersInRange(range, withString: text)
        
        return newString.characters.count <= maxText
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        textView.resignFirstResponder()
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
                charactersLeftLabel.text = ""
            } else {
                if minText - textView.text.characters.count > 0 {
                    charactersLeftLabel.text = "\(minText - textView.text.characters.count) / \(maxText - textView.text.characters.count)"
                } else {
                    charactersLeftLabel.text = "\(maxText - textView.text.characters.count)"
                }
            }
        }
        
        if textView.text.characters.count >= minText && textView.textColor != UIColor.lightGrayColor() {
            tabIsValid = true
        } else {
            tabIsValid = false
        }
    }
}
