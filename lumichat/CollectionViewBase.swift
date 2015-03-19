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


class CollectionViewBase: UICollectionViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout, ButtonCellControllerDelegate, ModifyButtonDelegate
{
    @IBOutlet weak var navBarTitle: UINavigationItem!
    @IBOutlet weak var textBox: UITextField!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet var myCollectionView: UICollectionView!
    
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
    var link:String = "Home"
    var editMode = false
    let coreDataObject = CoreDataController()
    var buttonCell = ButtonCell()
    var size = 0
    var rowSet = NSMutableSet()
    var colSet = NSMutableSet()
    
    
    var navBar = ""	// stores the title for the navigation bar
    var pageLink = ""	// stores the name of the row that was selected - used for DB table name
    var timer = NSTimer()
    var buttonTitle = ""

    
    @IBAction func menuButtonPressed(sender: UIButton)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in }
        alertController.addAction((cancelAction))
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default)
        {
            action in
            self.performSegueWithIdentifier("settingsSegue", sender: self)
        }
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
                var cells = self.collectionview.visibleCells()
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
            }
        }
        alertController.addAction(editAction)
        alertController.addAction(settingsAction)
        alertController.popoverPresentationController?.sourceView = sender as UIView
        self.presentViewController(alertController, animated: true) { () -> Void in }

    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func editButtonWasPressed(buttonTitle: String, didSucceed: Bool)
    {
        println("edit pressed")
        self.buttonTitle = buttonTitle
        performSegueWithIdentifier("toEdit", sender: self)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func callBackFromModalSaving(data: ButtonModel)
    {
        editOrModifyButton(data)
        configureEntireView(collectionview, pageLink: pageLink, title: navBar, navBarButtons: [])
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func callBackFromModalDelete()
    {
        configureEntireView(collectionview, pageLink: pageLink, title: navBar, navBarButtons: [])
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func degreesToRadians(x: Double) -> CGFloat
    {
        return CGFloat(M_PI * x / 180.0)
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
    
    /* ******************************************************************************************************
    *	Updates the database if the buttons were reordered
    ******************************************************************************************************* */
    override func viewDidDisappear(animated: Bool)
    {
        if( reordered == true)
        {
            coreDataObject.deleteCategoriesFromContext()
            var counter = 0
            for item in cellArray
            {
                let title = (item as ButtonCell).buttonLabel.text!
                let image = (item as ButtonCell).buttonObject!.imageTitle
                let longDescription = (item as ButtonCell).buttonObject!.longDescription
                let link = title.stringByReplacingOccurrencesOfString(" ", withString: "")
                
                coreDataObject.createInManagedObjectContextTable(title, image: image, longDescription: longDescription, table: link, index: counter, linkedPage: "")
                counter++
            }
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func viewWillAppear(animated: Bool)
    {
        configureEntireView(myCollectionView, pageLink: link, title: "Home", navBarButtons: [menuButton])

        menuButton.layer.borderColor = UIColor.blackColor().CGColor
        menuButton.layer.borderWidth = 4
        textBox.inputView = UIView()        // textBox is used to get input from bluetooth
        textBox.becomeFirstResponder()
        buttonCell.delegate = self
    }
    
    /************************************************************************************************
    *	From LXcollectionView
    *********************************************************************************************** */
    //    override func viewDidLoad()
    //    {
    //        //        navBarTitle.title = navBar
    //
    //        let backButton = Util().createNavBarBackButton(self)
    //        let back = UIBarButtonItem(customView: backButton)
    //        navBarTitle.leftBarButtonItem = back
    //
    //        //        configureEntireView(mycollectionview, pageLink: pageLink, title: navBar, navBarButtons: [backButton, createButton])
    //        //        buttonCell.delegate = self
    //    }
    
    func handleBack()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func configureEntireView(collectionView: UICollectionView, pageLink: String, title: String, navBarButtons: [UIButton])
    {
        self.navBarTitle.title = title
        buttons.removeAllObjects()
        cellArray.removeAllObjects()
        setup(collectionView)
        setLayout()
        setLink(pageLink)
        setTapRecognizer()
        getButtonsFromDB()
        collectionview.reloadData()
        scanner.reloadData(layout.collectionViewContentSize(), numButtons: buttons.count)
        scanner.setupNavBar(navBarButtons)
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
//        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
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
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func getButtonsFromDB()
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
                var linkedPage = buttonDetails.linkedPage
                
                // If there really is data, configure the button and add it to the array of buttons
                if(title != "")
                {
                    var buttonObject = ButtonModel(title: title, imageTitle: image, longDescription: longDescription, imagePath: "", linkedPage: linkedPage)
                    buttons.addObject(buttonObject)
                }
            }
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func startShakingButtons() -> CAAnimation
    {
        var transform = CATransform3DMakeRotation(0.08, 0, 0, 1)
        var animation = CABasicAnimation(keyPath: "transform")
        animation.toValue = NSValue(CATransform3D: transform)
        animation.autoreverses = true
        animation.duration = 0.1
        animation.repeatCount = HUGE
        return animation
    }
    
    /******************************************************************************************
    *   This dynamically calculates the size of the cells so that they all fit on the screen.
    *   It makes them all square.
    ******************************************************************************************/
    override func viewDidLayoutSubviews()
    {
        var cellMaxSide = 0
        var rows:Float = 9999
        var cols:Float = 9999
        
        do{
            cols = floorf(Float(collectionview.bounds.width + 35)/(Float(cellMaxSide + 1) + 35))
            rows = floorf(Float(collectionview.bounds.height + 35)/(Float(cellMaxSide + 1) + 35))
            ++cellMaxSide
        }while( Int(cols * rows) >= cellArray.count + 1)
        
        var dim = CGFloat(cellMaxSide)
        size = cellMaxSide
        
        (self.collectionViewLayout as UICollectionViewFlowLayout).itemSize = CGSizeMake(dim, dim)
        
        
        rowSet.removeAllObjects()
        colSet.removeAllObjects()
        var currItem = 0
        for (currItem = 0; currItem < cellArray.count; currItem++)
        {
            var cell = collectionview.cellForItemAtIndexPath(NSIndexPath(forItem: currItem, inSection: 0)) as ButtonCell
            
            rowSet.addObject(cell.frame.origin.y)
            colSet.addObject(cell.frame.origin.x)
        }
        
        scanner.setRowsAndCols(rowSet.count, cols: colSet.count) // Tell the scanner how many rows/cols
    }
    
    func addArrowIndicator(cell: ButtonCell)
    {
        let image = UIImage(named: "ArrowOverlay")
        let imageView = UIImageView(image: image)
        let x = cell.bounds.width - 28
        imageView.frame = CGRectMake(x, 8, 20, 20)
        cell.addSubview(imageView)

    }

    /* *******************************************************************************************************
    *
    ******************************************************************************************************** */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 5
    }
    
    /* *******************************************************************************************************
    *
    ******************************************************************************************************** */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 5
    }
    
    /* *******************************************************************************************************
    *
    ******************************************************************************************************** */
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
    *   Gets called when the collection view is reloaded and the view is being populated. This handles
    *   presenting the selected button style.
    ******************************************************************************************************* */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let buttonObject = self.buttons[indexPath.item] as ButtonModel
        var buttonCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as ButtonCell
        buttonCell.setup(buttonObject)
        buttonCell.delegate = self
        if buttonObject.linkedPage != ""
        {
            addArrowIndicator(buttonCell)
        }

        cellArray.addObject(buttonCell)
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
    

    /* *******************************************************************************************************
    *	Once the second to last cell is displayed, start  new thread that will execute in 0.2 seconds so
    *   that the final cell has been displayed and then start shaking them all.
    ******************************************************************************************************** */
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.row == buttons.count - 1
        {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2*Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
                var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                if(appDelegate.editMode)
                {
                    //                self.scanner.stopScan()
                    var cells = self.collectionview.visibleCells()
                    for(var i = 0; i < cells.count; i++)
                    {
                        cells[i].addAnimation(self.startShakingButtons(), forKey: "shake")
                    }
                    
                    self.navBarTitle.title = self.navBarTitle.title?.stringByAppendingString(" (Edit Mode)")
                }
            }
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
        let numberOfButtons = buttons.count
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

            scanner.cellArray.removeAllObjects()
            cellArray.removeAllObjects()

            var button = self.buttons[fromIndexPath.item] as UIButton
            self.buttons.removeObjectAtIndex(fromIndexPath.item)
            self.buttons.insertObject(button, atIndex: toIndexPath.item)

            collectionview.reloadData()
            scanner.reloadData(layout.collectionViewContentSize(), numButtons: buttons.count)
        }
    }
    
    /* ***********************************************************************************************************
    *	Gets called when the user taps the screen. If using srial scan, it calls for the button to pressed, which
    *   plays the audio. If a different scan mode, it checks if it was the first tap or second tap. First tap changes
    *   scan mode, second selection, makes the selection.
    *********************************************************************************************************** */
    func tapHandler(gesture: UITapGestureRecognizer)
    {
        scanner.selectionMade(false)
        if( scanner.secondStageOfSelection == false)
        {
            if !scanner.navBarScanning
            {
                let title = (buttons[scanner.index] as ButtonModel).title
                if title == "Notes"
                {
                    performSegueWithIdentifier("toList", sender: self)
                }
                else
                {
                    let pageLink = (buttons[scanner.index] as ButtonModel).linkedPage!
                    if pageLink != ""
                    {
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as CollectionViewBase
                        vc.link = pageLink
                        navigationController?.pushViewController(vc, animated: true)
                    }
                    else
                    {
                        println("speak word")
                    }
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
//        if segue.identifier == "showDetail"
//        {
//            var index = scanner.index
//            var title = (buttons[index] as ButtonModel).title
//            let detailsViewController = segue.destinationViewController as LXCollectionViewController1
//            detailsViewController.navBar = title
//            detailsViewController.pageLink = title.stringByReplacingOccurrencesOfString(" ", withString: "")
//        }
        if segue.identifier == "toList"
        {
            let controller = segue.destinationViewController as ListViewController
            
        }
        else if segue.identifier == "toCreate"
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
    
    
    /******************************************************************************************
    * From LXCollectionView
    ******************************************************************************************/
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
//    {
//        if( string == " ")
//        {
//            scanner.selectionMade(true)
//        }
//        else if( string == "\n")
//        {
//            println("new line")
//        }
//        
//        return false
//    }
    

    
    
    
    
}