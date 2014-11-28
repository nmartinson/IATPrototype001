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
        pageLink = pageLink.stringByReplacingOccurrencesOfString(" ", withString: "_").lowercaseString
		
		navBarTitle.title = navBar
        setup(mycollectionview)
        setLayout()
        setLink(pageLink)
        setTapRecognizer()
        getButtonsFromDB()
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
			if let viewController = segue.destinationViewController as? CreateButtonViewController{
				viewController.availableData = {[weak self]
					(data) in
					if let weakSelf = self{
						weakSelf.wordEntered(data)
					}
				}
			}
		}
	}
	
	@IBAction func createButtonPressed(sender: AnyObject)
	{
		performSegueWithIdentifier("toCreate", sender: self)
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
	
	
    /* ***********************************************************************************************************
    *	Gets called when the user taps the screen. If using srial scan, it calls for the button to pressed, which
    *   plays the audio. If a different scan mode, it checks if it was the first tap or second tap. First tap changes
    *   scan mode, second selection, makes the selection.
    *********************************************************************************************************** */
	func tapHandler(gesture: UITapGestureRecognizer)
	{
        scanner.selectionMade(true)
	}

}
