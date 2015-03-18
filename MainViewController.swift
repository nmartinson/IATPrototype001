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
    @IBOutlet var mycollectionview: UICollectionView!
    
    @IBOutlet weak var settings: UIButton!
    
    
    
    
    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        
        configureEntireView(mycollectionview, pageLink: "Categories", title: "Home", navBarButtons: [settings])
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.editMode = false

        settings.layer.borderColor = UIColor.blackColor().CGColor
        settings.layer.borderWidth = 4
    }
    
    
    /* ******************************************************************************************************
    *	Updates the database if the buttons were reordered
    ******************************************************************************************************* */
    override func viewDidDisappear(animated: Bool)
    {
        if( reordered == true)
        {
            coreDataObject.deleteCategoriesFromContext()
            var counter = 0
            for item in cellArray
            {
                var title = (item as ButtonCell).buttonLabel.text!
                var image = (item as ButtonCell).imageString
                var longDescription = (item as ButtonCell).sentenceString
                let link = title.stringByReplacingOccurrencesOfString(" ", withString: "")
                
                coreDataObject.createInManagedObjectContextCategories(title, image: image, link: link, presses: 0)
            }
        }
    }
    
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
    
    
    /* *******************************************************************************************************************
    *	Gets called automatically when a row in the table gets selected.  It passes the name of the row to the view
    *	controller that is about to be presented (LXCollectionViewController1), which is used as the name of the DB table
    *	that stores the buttons associated with that row name.
    ******************************************************************************************************************* */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if segue.identifier == "showDetail"
        {
            var index = scanner.index
            var title = buttons[index].titleForState(.Normal)!
            let detailsViewController = segue.destinationViewController as LXCollectionViewController1
            detailsViewController.navBar = title
            detailsViewController.pageLink = title.stringByReplacingOccurrencesOfString(" ", withString: "")
        }
        else if segue.identifier == "toList"
        {
            let controller = segue.destinationViewController as ListViewController
            
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func getButtonsFromDB()
    {
        let (success, table) = coreDataObject.getTables("Home")
        if success
        {
            for buttonDetails in table!
            {
                var title = buttonDetails.title
                var image = buttonDetails.image
                var longDescription = buttonDetails.longDescription
                var index = buttonDetails.index
                
                // If there really is data, configure the button and add it to the array of buttons
                if(title != "")
                {
                    var button = UIButton.buttonWithType(.System) as UIButton
                    button.setTitle(title, forState: .Normal) // stores the title
                    button.setTitle(image, forState: .Selected)	// Stores the image string
                    button.setTitle(longDescription, forState: .Highlighted) // stores the longDescription
                    buttons.addObject(button)
                }
            }
        }

    }

    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    override func tapHandler(gesture: UITapGestureRecognizer)
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
}