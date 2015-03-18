//  LXCollectionViewController.swift
//  DraggableButtonTesting
//
//  Created by Nick Martinson on 8/14/14.
//  Copyright (c) 2014 IAT. All rights reserved.
//
//

import Foundation
import UIKit
import CoreData

class LXCollectionViewController1: CollectionViewBase, ButtonCellControllerDelegate, ModifyButtonDelegate
{
	@IBOutlet weak var createButton: UIButton!
    @IBOutlet var mycollectionview: UICollectionView!
    
	var navBar = ""	// stores the title for the navigation bar
	var pageLink = ""	// stores the name of the row that was selected - used for DB table name
	var timer = NSTimer()
    var buttonTitle = ""
    var db = DBController.sharedInstance
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
    }
    
	/************************************************************************************************
	*	Gets called immediately when this view is loaded.  It configures all the necessary components
	*********************************************************************************************** */
	override func viewDidLoad()
	{
        navBarTitle.title = navBar
        
        let backButton = Util().createNavBarBackButton(self)
        let back = UIBarButtonItem(customView: backButton)
        navBarTitle.leftBarButtonItem = back
        
        configureEntireView(mycollectionview, pageLink: pageLink, title: navBar, navBarButtons: [backButton, createButton])
        buttonCell.delegate = self
	}
    

    
    
	/* ******************************************************************************************************
	*	Updates the database if the buttons were reordered
	******************************************************************************************************* */
	override func viewDidDisappear(animated: Bool)
	{
		if( reordered == true)
		{
            coreDataObject.deleteTableFromContext(link)
            var counter = 0
            for item in cellArray
            {
                var title = (item as ButtonCell).buttonLabel.text!
                var image = (item as ButtonCell).imageString
                var longDescription = (item as ButtonCell).sentenceString
                coreDataObject.createInManagedObjectContextTable(title, image: image, longDescription: longDescription, table: link, index: counter, linkedPage: "")
                counter++
            }
 
		}
	}
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func getButtonsFromDB()
    {
        let (success, table) = coreDataObject.getTables(link)
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
    
	/* ************************************************************************************************************
	*	When the "Create Button" button is pressed, this configures the current ViewController to retrieve the data
	*	that is entered in the create button form.
	************************************************************************************************************* */
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
	{
		if segue.identifier == "toCreate"
		{
			timer.invalidate()	// stop the scanner
			if let viewController = segue.destinationViewController as? CreateButtonTableViewController
            {
                viewController.delegate = self
			}
		}
        else if segue.identifier == "toEdit"
        {
            timer.invalidate()	// stop the scanner
            if let viewController = segue.destinationViewController as? EditButtonTableViewController
            {
                viewController.buttonTitle = buttonTitle
                viewController.delegate = self
            }
        }

	}

    
	/* ************************************************************************************************************
	*	This function gets called when the user presses the save button when creating a new button. It inserts the
	*	new button data into the database and adds the button to the button array.
	************************************************************************************************************* */
    func editOrModifyButton(data: ButtonModel)
	{
        (scanner as ScanController).cellArray.removeAllObjects()

        let title = data.title
        let longDescription = data.longDescription
        let imagePath = data.imagePath
        let linkedPage = data.linkedPage!

        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if(appDelegate.editMode)
        {
            coreDataObject.updateButtonWith(buttonTitle, newTitle: title, longDescription: longDescription, image: imagePath, linkedPage: linkedPage)
        }
        else
        {
            let (success, tableItems) = coreDataObject.getTables(link)
            if success
            {
                coreDataObject.createInManagedObjectContextTable(title, image: imagePath, longDescription: longDescription, table: link, index: buttons.count, linkedPage: linkedPage)
                var button = UIButton.buttonWithType(.System) as UIButton
                button.setTitle(title, forState: .Normal) // stores the button label
                button.setTitle(longDescription, forState: .Highlighted) // stores the extra longDescription
                
                // Change button title
                button.setTitle(imagePath, forState: .Selected)	// Stores the image string
                buttons.addObject(button)
            }
        }

        collectionview.reloadData()
	}
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func createButtonPressed()
    {
        performSegueWithIdentifier("toCreate", sender: self)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @IBAction func actionSheetButtonPressed(sender: AnyObject)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in }
        alertController.addAction((cancelAction))
        
        let createAction = UIAlertAction(title: "Create", style: .Default) { (action) -> Void in
            self.createButtonPressed()
        }
        alertController.addAction(createAction)
        
        let editAction = UIAlertAction(title: "Edit", style: .Destructive) { (action) -> Void in
            var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.editMode = !appDelegate.editMode
            if(appDelegate.editMode)
            {
//                self.scanner.stopScan()
                var cells = self.mycollectionview.visibleCells()
                for(var i = 0; i < cells.count; i++)
                {
                    cells[i].addAnimation(self.startShakingButtons(), forKey: "shake")
                }
                
                self.navBarTitle.title = self.navBarTitle.title?.stringByAppendingString(" (Edit Mode)")
            }
            else
            {
                self.navBarTitle.title = self.navBarTitle.title?.stringByReplacingOccurrencesOfString(" (Edit Mode)", withString: "")
                self.collectionview.reloadData()
//                var cells = self.mycollectionview.visibleCells()
//                for(var i = 0; i < cells.count; i++)
//                {
//                    self.cellArray[i].view
//                    cells[i].removeAnimationForKey("shake")
//                }
            }
        }
        alertController.addAction(editAction)
        
        alertController.popoverPresentationController?.sourceView = sender as UIView
        self.presentViewController(alertController, animated: true) { () -> Void in }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func editButtonWasPressed(buttonTitle: String, didSucceed: Bool)
    {
        self.buttonTitle = buttonTitle
        performSegueWithIdentifier("toEdit", sender: self)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func callBackFromModalSaving(data: ButtonModel)
    {
        editOrModifyButton(data)
        configureEntireView(mycollectionview, pageLink: pageLink, title: navBar, navBarButtons: [])
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func callBackFromModalDelete()
    {
        configureEntireView(mycollectionview, pageLink: pageLink, title: navBar, navBarButtons: [])
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func degreesToRadians(x: Double) -> CGFloat
    {
        return CGFloat(M_PI * x / 180.0)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
//    func startShakingButtons() -> CAAnimation
//    {
//        var transform = CATransform3DMakeRotation(0.08, 0, 0, 1)
//        var animation = CABasicAnimation(keyPath: "transform")
//        animation.toValue = NSValue(CATransform3D: transform)
//        animation.autoreverses = true
//        animation.duration = 0.1
//        animation.repeatCount = HUGE
//        return animation
//    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if( string == " ")
        {
            scanner.selectionMade(true)
        }
        else if( string == "\n")
        {
            println("new line")
        }
        
        return false
    }
    
    
}
