//
//  CollectionViewBase.swift
//  lumichat
//
//  Created by Nick Martinson on 11/27/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class CollectionViewBase: UICollectionViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout, ButtonCellControllerDelegate
{
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    var layout:LXReorderableCollectionViewFlowLayout!
    var fromIndexPath: NSIndexPath!
    var reordered = false	// gets set true if a button has changed positions - indicates to update DB
    var buttonStyle = 0	// from settings
    var buttons: NSMutableArray = []	// stores buttons
    var cellArray: NSMutableArray = []	// stores ButtonCells
    var scanner = ScanController.sharedInstance
    var buttonSize = 0	// from settings
    var selectedIndexPath:NSIndexPath!
    var collectionview:UICollectionView!
    var tapRec: UITapGestureRecognizer!
    var link:String!
    var editMode = false
    let coreDataObject = CoreDataController()
    var buttonCell = ButtonCell()
    
    func configureEntireView(collectionView: UICollectionView, pageLink: String, title: String)
    {
        buttons.removeAllObjects()
        cellArray.removeAllObjects()
        setup(collectionView)
        setLayout()
        setLink(pageLink)
        setTapRecognizer()
        getButtonsFromDB()
        collectionview.reloadData()
        scanner.reloadData(layout.collectionViewContentSize())
        configureButtons()
    }
    
    // configures the default CollectionView element for manipulating
    func setup(collectionview: UICollectionView)
    {
        self.collectionview = collectionview
    }
    
    // sets the link for accessing the database for each page
    func setLink(link: String)
    {
        self.link = link
    }
    
    // configures the collection view layout
    func setLayout()
    {
        layout = self.collectionview.collectionViewLayout as LXReorderableCollectionViewFlowLayout
        layout.minimumInteritemSpacing = CGFloat(15)
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    //configures the tap recoginizer
    func setTapRecognizer()
    {
        self.tapRec = UITapGestureRecognizer()
        tapRec.addTarget( self, action: "tapHandler:")
        tapRec.numberOfTapsRequired = 1
        tapRec.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapRec)
    }
    
    // gets the users preferences for button size and style
    func configureButtons()
    {
        // Pull in all the data stored in the settings
        var defaults = NSUserDefaults.standardUserDefaults()
        buttonSize = defaults.integerForKey("buttonSize")
        buttonStyle = defaults.integerForKey("buttonStyle")
        setButtonSize()
    }
    
    // pulls buttons from the DB and configures the buttons
    func getButtonsFromDB(){}
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        selectedIndexPath = indexPath
    }
    
    /* *******************************************************************************************************
    *	Returns the number of items in each section of the collection view... We are only using one section.
    ******************************************************************************************************** */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.buttons.count
    }
    
    /* *******************************************************************************************************
    *
    ******************************************************************************************************** */
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 50.0
    }
    
    /* *******************************************************************************************************
    *	Updates the database when the buttons are reordered
    ******************************************************************************************************** */
//    func collectionViewReordered()
//    {
//        var database = db.getDB("UserDatabase.sqlite")
//        database.open()
//        database.executeUpdate("DROP TABLE \(link)", withArgumentsInArray: nil)
//        database.executeUpdate("CREATE TABLE \(link)(number INT primary key, title TEXT, longDescription TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
//        
//        var counter = 0
//        for item in cellArray
//        {
//            var title = (item as ButtonCell).buttonLabel.text!
//            var image = (item as ButtonCell).imageString
//            var longDescription = (item as ButtonCell).sentenceString
//            var array = [counter, title, longDescription, image, 1 ]
//            database.executeUpdate("INSERT INTO \(link)(number, title, longDescription, image, presses) values(?,?,?,?,?)", withArgumentsInArray: array)
//            counter++
//        }
//        database.close()
//    }
    
    /* *******************************************************************************************************
    *   Gets called when the collection view is reloaded and the view is being populated. This handles
    *   presenting the selected button style.
    ******************************************************************************************************* */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var button = self.buttons[indexPath.item] as UIButton
        var buttonCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as ButtonCell
        buttonCell.setup(button)
        buttonCell.delegate = self
        
        if( reordered == false)
        {
            cellArray.addObject(buttonCell)
        }
        scanner.addCell(buttonCell)
        
        
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
            
            var buttonCell = scanner.cellArray[fromIndexPath.item] as ButtonCell
            scanner.cellArray.removeObjectAtIndex(fromIndexPath.item)
            scanner.cellArray.insertObject(cell, atIndex: toIndexPath.item)
            
            collectionview.reloadData()
            scanner.reloadData(layout.collectionViewContentSize())
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
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func editButtonWasPressed(buttonTitle: String, didSucceed: Bool){}
}