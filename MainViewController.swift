//
//  MainViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 11/1/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MainViewController : CollectionViewBase, UITextFieldDelegate
{
//    @IBOutlet var mycollectionview: UICollectionView!
    
    

    /******************************************************************************************
    *
    ******************************************************************************************/
//    override func viewWillAppear(animated: Bool)
//    {
//        super.viewWillAppear(true)
//        
//        configureEntireView(mycollectionview, pageLink: "Home", title: "Home", navBarButtons: [settings])
//        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//        appDelegate.editMode = false
//
//
//    }
    
    
//    /* ******************************************************************************************************
//    *	Updates the database if the buttons were reordered
//    ******************************************************************************************************* */
//    override func viewDidDisappear(animated: Bool)
//    {
//        if( reordered == true)
//        {
//            coreDataObject.deleteCategoriesFromContext()
//            var counter = 0
//            for item in cellArray
//            {
//                let title = (item as ButtonCell).buttonLabel.text!
//                let image = (item as ButtonCell).buttonObject!.imageTitle
//                let longDescription = (item as ButtonCell).buttonObject!.longDescription
//                let link = title.stringByReplacingOccurrencesOfString(" ", withString: "")
//                
//                coreDataObject.createInManagedObjectContextCategories(title, image: image, link: link, presses: 0)
//            }
//        }
//    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if( string == " ")
        {
            scanner.selectionMade(false)
            if( scanner.secondStageOfSelection == false)
            {
                if !scanner.navBarScanning
                {
                    let title = buttons[scanner.index].titleForState(.Normal)!
                    if title == "Notes"
                    {
                        performSegueWithIdentifier("toList", sender: self)
                    }
                    else
                    {
                        performSegueWithIdentifier("showDetail", sender: self)
                    }
                }
            }
        }
        else if( string == "\n")
        {
            println("new line")
        }
        
        return false
    }
    
}