//
//  EditButtonTableViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 3/17/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import CoreData

class EditButtonTableViewController: ModifyButtonTableViewController
{
    var link:String = ""
    var buttonTitle:String = ""
    var db = DBController.sharedInstance
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func viewDidLoad()
    {
        super.viewDidLoad()
        populateFields()
        
    }
    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func populateFields()
    {
        let coreDataObject = CoreDataController()
        let (success, buttons) = coreDataObject.getButtonWithTitle(buttonTitle)
        if let button = buttons?[0]{
            if success
            {
                buttonTitleField.text = button.title
                textDescription.text = button.longDescription
                buttonImage.image = loadImage(button.image)
                
                // if the button has a page link, set up that in the view
                if let index = find(pages, button.linkedPage)
                {
                    pagePicker.selectRow(index, inComponent: 0, animated: true) // select the proper page
                    linkSegment.selectedSegmentIndex = 1 // change link segment to 'Yes'
                    hidePageLinkCell = false // make it so that the page picker is displayed
                }
                
            }
        }
    }
    
    /* ************************************************************************************************
    *	Loads the specified image that is in the database for that button
    ************************************************************************************************ */
    func loadImage(title: String!) -> UIImage
    {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let imagePath = documentDirectory.stringByAppendingPathComponent(title)
        var image = UIImage(contentsOfFile: imagePath)
        
        return image!
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @IBAction func deleteButtonPressed(sender: AnyObject)
    {
        CoreDataController().deleteButtonWithTitle(buttonTitle)
        delegate?.callBackFromModalDelete()
        dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
}