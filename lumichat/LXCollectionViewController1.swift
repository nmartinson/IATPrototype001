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

class LXCollectionViewController1: CollectionViewBase
{
	@IBOutlet weak var createButton: UIButton!
    @IBOutlet var mycollectionview: UICollectionView!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
	var navBar = ""	// stores the title for the navigation bar
	var pageLink = ""	// stores the name of the row that was selected - used for DB table name
	var timer = NSTimer()
    var buttonTitle = ""
    var db = DBController.sharedInstance
    
    override func viewWillAppear(animated: Bool)
    {
        collectionview.reloadData()
        scanner.reloadData(layout.collectionViewContentSize())
        configureButtons()
    }
    
	/************************************************************************************************
	*	Gets called immediately when this view is loaded.  It configures all the necessary components
	*********************************************************************************************** */
	override func viewDidLoad()
	{
        buttons.removeAllObjects()
        cellArray.removeAllObjects()
		navBarTitle.title = navBar
        setup(mycollectionview)
        setLayout()
        setLink(pageLink)
        setTapRecognizer()
        getButtonsFromDB()
        configureButtons()

	}
    
	/* ******************************************************************************************************
	*	Updates the database if the buttons were reordered
	******************************************************************************************************* */
	override func viewDidDisappear(animated: Bool)
	{
		if( reordered == true)
		{
//            var database = db.getDB("UserDatabase.sqlite")
//            database.open()
//			database.executeUpdate("DROP TABLE \(super.link)", withArgumentsInArray: nil)
//			database.executeUpdate("CREATE TABLE \(super.link)(number INT primary key, title TEXT, longDescription TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
//			
//			var counter = 0
//			for item in cellArray
//			{
//				var title = (item as ButtonCell).buttonLabel.text!
//				var image = (item as ButtonCell).imageString
//                var longDescription = (item as ButtonCell).sentenceString
//				var array = [counter, title, longDescription, image, 1 ]
//				database.executeUpdate("INSERT INTO \(super.link)(number, title, longDescription, image, presses) values(?,?,?,?,?)", withArgumentsInArray: array)
//				counter++
//			}
//			database.close()
            
            
            coreDataObject.deleteTableFromContext(link)
            var counter = 0
            for item in cellArray
            {
                var title = (item as ButtonCell).buttonLabel.text!
//                println("title: \(title)")
                var image = (item as ButtonCell).imageString
                var longDescription = (item as ButtonCell).sentenceString
                coreDataObject.createInManagedObjectContextTable(title, image: image, longDescription: longDescription, entity: "Tables", table: link, index: counter)
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
//                println("title: \(title)   index: \(index)")
                
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
			if let viewController = segue.destinationViewController as? CreateButtonViewController
            {
				viewController.availableData = {[weak self]
					(data) in
					if let weakSelf = self{
						weakSelf.wordEntered(data)
					}
				}
			}
		}
        else if segue.identifier == "toEdit"
        {
            timer.invalidate()	// stop the scanner
            if let viewController = segue.destinationViewController as? EditButtonController
            {
                viewController.link = buttonTitle
                println("Button title: \(buttonTitle)")
                viewController.availableData = {[weak self]
                    (data) in
                    if let weakSelf = self{
                        weakSelf.wordEntered(data)
                    }
                }
            }
        }

	}

    
	/* ************************************************************************************************************
	*	This function gets called when the user presses the save button when creating a new button. It inserts the
	*	new button data into the database and adds the button to the button array.
	************************************************************************************************************* */
    func wordEntered(data: [String: NSObject])
	{
        scanner.cellArray.removeAllObjects()

        let title = data["title"] as String
        let longDescription = data["longDescription"] as String
        let imagePath = data["path"] as String
		
        let (success, tableItems) = coreDataObject.getTables(link)
        if success
        {
            coreDataObject.createInManagedObjectContextTable(title, image: imagePath, longDescription: longDescription, entity: "Tables", table: link, index: buttons.count)
        }

		var button = UIButton.buttonWithType(.System) as UIButton
		button.setTitle(title, forState: .Normal) // stores the button label
        button.setTitle(longDescription, forState: .Highlighted) // stores the extra longDescription
		
		// Change button title
		button.setTitle(imagePath, forState: .Selected)	// Stores the image string
		buttons.addObject(button)
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
    func editButtonPressed()
    {
        performSegueWithIdentifier("toEdit", sender: self)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @IBAction func actionSheetButtonPressed(sender: AnyObject)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            println("cancel")
        }
        alertController.addAction((cancelAction))
        let createAction = UIAlertAction(title: "Create", style: .Default) { (action) -> Void in
            self.createButtonPressed()
        }
        alertController.addAction(createAction)
        let deleteAction = UIAlertAction(title: "Edit", style: .Destructive) { (action) -> Void in
            var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.editMode = !appDelegate.editMode
            if(appDelegate.editMode)
            {
                self.scanner.stopScan()
                self.navBarTitle.title = self.navBarTitle.title?.stringByAppendingString(" (Edit Mode)")
            }
            else
            {
                self.navBarTitle.title = self.navBarTitle.title?.stringByReplacingOccurrencesOfString(" (Edit Mode)", withString: "")

            }
        }
        alertController.addAction(deleteAction)
        
        alertController.popoverPresentationController?.sourceView = sender as UIView
        self.presentViewController(alertController, animated: true) { () -> Void in }
    }
    


}
