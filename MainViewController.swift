//
//  MainViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 11/1/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

class MainViewController : UICollectionViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout
{
    var layout:LXReorderableCollectionViewFlowLayout!
    var fromIndexPath: NSIndexPath!
    var reordered = false	// gets set true if a button has changed positions - indicates to update DB
    var buttonStyle = 0	// from settings
    var buttons: NSMutableArray = []	// stores buttons
    var cellArray: NSMutableArray = []	// stores ButtonCells
    var scanner = ScanController.sharedInstance
    var buttonSize = 0	// from settings
    @IBOutlet weak var collectionview: UICollectionView!
    var selectedIndexPath:NSIndexPath!
    var tapRec: UITapGestureRecognizer!

    override func viewWillAppear(animated: Bool) {
        scanner.size(layout.collectionViewContentSize())
        collectionview.reloadData()
        var defaults = NSUserDefaults.standardUserDefaults()
        buttonSize = defaults.integerForKey("buttonSize")
        buttonStyle = defaults.integerForKey("buttonStyle")
        setButtonSize()
    }
    
    override func viewDidLoad()
    {
        println("About to zip")
        var pathForZip = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        let zipPath:NSString = pathForZip.stringByAppendingString("/images/files.zip")
        let filesPath:NSString = pathForZip.stringByAppendingString("images/buttonTest.jpg")
        var array:NSArray = [filesPath]
        var err:NSError? = NSError()
        var newPath = NSURL.fileURLWithPath(zipPath)
        SSZipArchive.createZipFileAtPath(zipPath, withFilesAtPaths: array)
        println("zipped")
        
        
        self.tapRec = UITapGestureRecognizer()
        tapRec.addTarget( self, action: "tapHandler:")
        tapRec.numberOfTapsRequired = 1
        tapRec.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapRec)
        
        var defaults = NSUserDefaults.standardUserDefaults()
        buttonSize = defaults.integerForKey("buttonSize")

        setButtonSize()
        
        layout = self.collectionView.collectionViewLayout as LXReorderableCollectionViewFlowLayout
        layout.minimumInteritemSpacing = CGFloat(15)
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        var path = createDBPath()
        let database = FMDatabase(path: path)
        database.open()
        var results = FMResultSet()
        
        // If a DB table exists for the current category, extract all the button information
        if(database.tableExists("categories"))
        {
            results = database.executeQuery("SELECT * FROM categories",withArgumentsInArray: nil)
            
            while( results.next() )
            {
                var num = results.intForColumn("number")
                var title = results.stringForColumn("title") as String!
                var image = results.stringForColumn("image")
                
                // If there really is data, configure the button and add it to the array of buttons
                if(title != nil)
                {
                    var button = UIButton.buttonWithType(.System) as UIButton
                    button.setTitle(title, forState: .Normal)
                    button.setTitle(image, forState: .Selected)	// Stores the image string
                    button.setTitle("", forState: .Highlighted)
                    buttons.addObject(button)
                }
            }
        }
        database.close()
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
            detailsViewController.link = title.lowercaseString
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
    }
    
    /* *******************************************************************************************************
    *	Returns the number of items in each section of the collection view... We are only using one section.
    ******************************************************************************************************** */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.buttons.count
    }
    
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 50.0
    }
    
    
    /* *******************************************************************************************************
    *   Gets called when the collection view is reloaded and the view is being populated. This handles
    *   presenting the selected button style.
    ******************************************************************************************************* */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var button = self.buttons[indexPath.item] as UIButton
        var buttonCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as ButtonCell
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
            
            var button = self.buttons[fromIndexPath.item] as UIButton
            self.buttons.removeObjectAtIndex(fromIndexPath.item)
            self.buttons.insertObject(button, atIndex: toIndexPath.item)
        }
    }
    
    /* ************************************************************************************************
    *	This is
    ************************************************************************************************ */
    func tapHandler(gesture: UITapGestureRecognizer)
    {
        scanner.selectionMade(false)
        if( scanner.secondStageOfSelection == false)
        {
            performSegueWithIdentifier("showDetail", sender: self)
        }
    }
}