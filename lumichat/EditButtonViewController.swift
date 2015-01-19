//
//  EditButtonViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 11/29/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import CoreData

class EditButtonController: ModifyButtonController
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