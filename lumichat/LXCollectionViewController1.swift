//  LXCollectionViewController.swift
//  DraggableButtonTesting
//
//  Created by Nick Martinson on 8/14/14.
//  Copyright (c) 2014 IAT. All rights reserved.
//
//

import Foundation
import UIKit

class LXCollectionViewController1: UICollectionViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout
{
	@IBOutlet weak var navBarTitle: UINavigationItem!
	@IBOutlet weak var createButton: UIButton!
	@IBOutlet weak var scannerDrawer: ScannerDrawer!
    @IBOutlet var collectionview: UICollectionView!
	
    var layout:LXReorderableCollectionViewFlowLayout!
    var scanner = ScanController.sharedInstance
	var deck: NSMutableArray = []	// stores buttons
	var uibutton = UIButton.buttonWithType(.System) as UIButton
	var navBar = ""	// stores the title for the navigation bar
	var link = ""	// stores the name of the row that was selected - used for DB table name
	var timer = NSTimer()
	var timeInterval: Double = 0.0	// used as scan rate - from settings
	var buttonBorderColor = 0	// from settings
	var buttonBorderWidth: CGFloat = 10	// from settings
	var buttonStyle = 0	// from settings
	var buttonSize = 0	// from settings
	var scanMode = 0	// from settings
	var reordered = false	// gets set true if a button has changed positions - indicates to update DB
	var fromIndexPath: NSIndexPath!
	var cellArray: NSMutableArray = []	// stores ButtonCells
	var tapRec: UITapGestureRecognizer!
	var endIndex = 0;		// row scanning variable
	var startIndex = 0;	// row scanning variable
	var secondStageOfSelection = false	// set true if in the second stage of selection
	var elementScanningCounter = 0
	var index = 0
	var imagePath:String = ""
	var image:UIImage!

    
    
	/************************************************************************************************
	*	Gets called immediately when this view is loaded.  It configures all the necessary components
	*********************************************************************************************** */
	override func viewDidLoad()
	{
		super.viewDidLoad()
        
		self.tapRec = UITapGestureRecognizer()
		tapRec.addTarget( self, action: "tapHandler:")
		tapRec.numberOfTapsRequired = 1
		tapRec.numberOfTouchesRequired = 1
		self.view.addGestureRecognizer(tapRec)
		
//		navBarTitle.title = navBar
		layout = self.collectionView.collectionViewLayout as LXReorderableCollectionViewFlowLayout
		layout.minimumInteritemSpacing = CGFloat(15)
		layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
		// Pull in all the data stored in the settings
		var defaults = NSUserDefaults.standardUserDefaults()
		buttonSize = defaults.integerForKey("buttonSize")
		setButtonSize()
		
		var path = createDBPath()
		let database = FMDatabase(path: path)
		database.open()
		var results = FMResultSet()
		
        link = link.stringByReplacingOccurrencesOfString(" ", withString: "_").lowercaseString
		// If a DB table exists for the current category, extract all the button information
		if(database.tableExists("\(link)"))
		{
			results = database.executeQuery("SELECT * FROM \(link)",withArgumentsInArray: nil)
	
			while( results.next() )
			{
				var num = results.intForColumn("number")
				var title = results.stringForColumn("title")
		 		var image = results.stringForColumn("image")
                var description = results.stringForColumn("description")
				
				// If there really is data, configure the button and add it to the array of buttons
				if(title != nil)
				{
					var button = UIButton.buttonWithType(.System) as UIButton
					button.setTitle(title, forState: .Normal)
					button.setTitle(image, forState: .Selected)	// Stores the image string
                    button.setTitle(description, forState: .Highlighted)
					deck.addObject(button)
				}
			}
		}
        
		database.close()
        scanner.size(layout.collectionViewContentSize())
	}
	
	/* ************************************************************************************************
	*	Sets the button size
	*	0 = serial scan
	*	1 = block scan
	*	2 = row column scan
	*	3 = column row scan
	************************************************************************************************* */
	func setScanMode()
	{
		switch scanMode
		{
			case 0:
				timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("serialScan"), userInfo: nil, repeats: true)
			case 1:
				timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("blockScan"), userInfo: nil, repeats: true)
			case 2:
				timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("rowScan"), userInfo: nil, repeats: true)
			case 3:
				timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("columnScan"), userInfo: nil, repeats: true)
			default:
				println("Error")
		}
	}
	
	/* *************************************************************************************************
	*	Sets the button size
	*	0 = small button
	*	1 = medium button
	*	2 = large button
	************************************************************************************************* */
	func setButtonSize()
	{
		(self.collectionViewLayout as UICollectionViewFlowLayout).itemSize = Constants.getCellSize(buttonSize)
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
			database.executeUpdate("DROP TABLE \(link)", withArgumentsInArray: nil)
			database.executeUpdate("CREATE TABLE \(link)(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
			
			var counter = 0
			for item in cellArray
			{
				var title = (item as ButtonCell).buttonLabel.text!
				var image = (item as ButtonCell).imageString
                var description = (item as ButtonCell).sentenceString
				var array = [counter, title, description, image, 1 ]
				database.executeUpdate("INSERT INTO \(link)(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: array)
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
		let path = createDBPath()
		let database = FMDatabase(path: path)
		database.open()
        var mutablePath = data["path"] as String
//        mutablePath = mutablePath + ".jpg"
        if (mutablePath == "")
        {
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let imagePath = documentDirectory.stringByAppendingPathComponent("buttonTest.jpg")
            mutablePath = imagePath
//            UIImageJPEGRepresentation(data["image"] as? UIImage, 1).writeToFile(mutablePath, atomically: true)
        }
        
        var array = [deck.count, data["title"] as String, data["description"] as String, mutablePath as String, 1]
		
		database.executeUpdate("CREATE TABLE IF NOT EXISTS \(link)(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
		database.executeUpdate("INSERT INTO \(link)(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: array)
		database.close()
		
		var button = UIButton.buttonWithType(.System) as UIButton
		button.setTitle(data["title"] as? String, forState: .Normal)
        button.setTitle("description", forState: .Highlighted)
		
		// Change button tiltle
		button.setTitle(mutablePath, forState: .Selected)	// Stores the image string
    
		deck.addObject(button)
		collectionView.reloadData()// update the collection view so that the new button shows up
	}
	
	/* *****************************************************************************************************
	*	Creates and returns the file path to the database
	****************************************************************************************************** */
	func createDBPath() -> String
	{
		let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
		let docsPath: String = paths
		let path = docsPath.stringByAppendingPathComponent("UserDatabase.sqlite")
		return path
	}
	
	/* *******************************************************************************************************
	*	Returns the number of items in each section of the collection view... We are only using one section.
	******************************************************************************************************** */
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return self.deck.count
	}
	
	
	func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
	{
		return 50.0
	}

	
	/* *******************************************************************************************************
	*
	******************************************************************************************************* */
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
        println("cell for item")
		var button = self.deck[indexPath.item] as UIButton
		var buttonCell = collectionView.dequeueReusableCellWithReuseIdentifier("PlayingCardCell", forIndexPath: indexPath) as ButtonCell
		buttonCell.setup(button)

		if( reordered == false)
		{
			cellArray.addObject(buttonCell)
            scanner.addCell(buttonCell)
		}
		
		switch buttonStyle
		{
			case 0:
				buttonCell.buttonLabel.hidden = false
				buttonCell.buttonImageView.hidden = false
			case 1:
				buttonCell.buttonLabel.hidden = false
				buttonCell.buttonImageView.hidden = true
			case 2:
				buttonCell.buttonLabel.hidden = true
				buttonCell.buttonImageView.hidden = false
			default:
				println("Button style issue")
		}
		
		return buttonCell
	}

	/* ******************************************************************************************************
	*	Gets called when the user begins to drag the icon. The indexPath that the icon started at is stored
	*	for purposes of refactoring the cellArray
	****************************************************************************************************** */
	func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didBeginDraggingItemAtIndexPath indexPath: NSIndexPath!)
	{
		fromIndexPath = indexPath
	}
	
	/* ***********************************************************************************************************
	*	Gets called when the user ends the dragging of an icon. The starting indexPath is compared with the ending
	*	indexPath. If the same, no action is taken.  If different, the cellArray and button array are refactored
	*********************************************************************************************************** */
	func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didEndDraggingItemAtIndexPath toIndexPath: NSIndexPath!)
	{
		if( fromIndexPath != toIndexPath)
		{
			reordered = true
			var cell = cellArray[fromIndexPath.item] as ButtonCell
			self.cellArray.removeObjectAtIndex(fromIndexPath.item)
			self.cellArray.insertObject(cell, atIndex: toIndexPath.item)
		
			var button = self.deck[fromIndexPath.item] as UIButton
			self.deck.removeObjectAtIndex(fromIndexPath.item)
			self.deck.insertObject(button, atIndex: toIndexPath.item)
		}
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
