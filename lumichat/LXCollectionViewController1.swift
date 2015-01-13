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

        func getButtons() //-> (Bool, [Categories]?)
        {
            var buttonItem = [Tables]()
            let fetchRequest = NSFetchRequest(entityName: "Tables")
            fetchRequest
            let predicate = NSPredicate(format: "table = %@", link)
            fetchRequest.predicate = predicate
            if let fetchResults = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as? [Tables] {
                if fetchResults.count > 0
                {
                    for item in fetchResults
                    {
                        var title = item.title
                        var image = item.image
                        var longDescription = item.longDescription
    
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
    
                    buttonItem = fetchResults
    //                return (true, categoryTable)
                }
            }
    //        return (false, nil)
        }

    
	/* ******************************************************************************************************
	*	Updates the database if the buttons were reordered
	******************************************************************************************************* */
	override func viewDidDisappear(animated: Bool)
	{
		if( reordered == true)
		{
            var database = db.getDB("UserDatabase.sqlite")
            database.open()
			database.executeUpdate("DROP TABLE \(super.link)", withArgumentsInArray: nil)
			database.executeUpdate("CREATE TABLE \(super.link)(number INT primary key, title TEXT, longDescription TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
			
			var counter = 0
			for item in cellArray
			{
				var title = (item as ButtonCell).buttonLabel.text!
				var image = (item as ButtonCell).imageString
                var longDescription = (item as ButtonCell).sentenceString
				var array = [counter, title, longDescription, image, 1 ]
				database.executeUpdate("INSERT INTO \(super.link)(number, title, longDescription, image, presses) values(?,?,?,?,?)", withArgumentsInArray: array)
				counter++
			}
			database.close()
		}
	}
	
    override func getButtonsFromDB()
    {
        getButtons()
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

        var database = db.getDB("UserDatabase.sqlite")
        database.open()
        var mutablePath = data["path"] as String
        var array = [buttons.count, data["title"] as String, data["longDescription"] as String, mutablePath as String, 1]
		
		database.executeUpdate("CREATE TABLE IF NOT EXISTS \(link)(number INT primary key, title TEXT, longDescription TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
		database.executeUpdate("INSERT INTO \(link)(number, title, longDescription, image, presses) values(?,?,?,?,?)", withArgumentsInArray: array)
		database.close()
		
		var button = UIButton.buttonWithType(.System) as UIButton
		button.setTitle(data["title"] as? String, forState: .Normal) // stores the button label
        button.setTitle(data["longDescription"] as? String, forState: .Highlighted) // stores the extra longDescription
		
		// Change button title
		button.setTitle(mutablePath, forState: .Selected)	// Stores the image string
		buttons.addObject(button)
        collectionview.reloadData()
	}

    func createButtonPressed()
    {
        performSegueWithIdentifier("toCreate", sender: self)
    }
    
    func editButtonPressed()
    {
        performSegueWithIdentifier("toEdit", sender: self)
    }
    
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
        self.presentViewController(alertController, animated: true) { () -> Void in
            println("presented")
        }
    }
    


}
