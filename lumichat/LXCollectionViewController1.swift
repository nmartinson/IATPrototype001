//  LXCollectionViewController.swift
//  DraggableButtonTesting
//
//  Created by Nick Martinson on 8/14/14.
//  Copyright (c) 2014 IAT. All rights reserved.
//
//

import Foundation
import UIKit

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
        println("appear")
        collectionview.reloadData()
        scanner.reloadData(layout.collectionViewContentSize())
        configureButtons()
    }
    
	/************************************************************************************************
	*	Gets called immediately when this view is loaded.  It configures all the necessary components
	*********************************************************************************************** */
	override func viewDidLoad()
	{
        println("didload")
        buttons.removeAllObjects()
        cellArray.removeAllObjects()
        pageLink = pageLink.stringByReplacingOccurrencesOfString(" ", withString: "_").stringByReplacingOccurrencesOfString("-", withString: "_").lowercaseString
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
			let path = createDBPath()
			let database = FMDatabase(path: path)
			database.open()
			database.executeUpdate("DROP TABLE \(super.link)", withArgumentsInArray: nil)
			database.executeUpdate("CREATE TABLE \(super.link)(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
			
			var counter = 0
			for item in cellArray
			{
				var title = (item as ButtonCell).buttonLabel.text!
				var image = (item as ButtonCell).imageString
                var description = (item as ButtonCell).sentenceString
				var array = [counter, title, description, image, 1 ]
				database.executeUpdate("INSERT INTO \(super.link)(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: array)
				counter++
			}
			database.close()
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

        let path = createDBPath()
		let database = FMDatabase(path: path)
		database.open()
        var mutablePath = data["path"] as String
        var array = [buttons.count, data["title"] as String, data["description"] as String, mutablePath as String, 1]
		
		database.executeUpdate("CREATE TABLE IF NOT EXISTS \(link)(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
		database.executeUpdate("INSERT INTO \(link)(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: array)
		database.close()
		
		var button = UIButton.buttonWithType(.System) as UIButton
		button.setTitle(data["title"] as? String, forState: .Normal)
        button.setTitle(data["description"] as? String, forState: .Highlighted)
		
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
