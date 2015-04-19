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
    var previousPage = ""
    var editMode = false
    let coreDataObject = CoreDataController()
    var buttonCell = ButtonCell()
    var size = 0
    var rowSet = NSMutableSet()
    var colSet = NSMutableSet()
    var currentlyDragging = false
    
    var navBar = ""	// stores the title for the navigation bar
    var timer = NSTimer()
    var buttonTitle = ""
    private var foregroundNotification: NSObjectProtocol!

    
    /* ************************************************************************************************
    *   Creates the actionsheet that is presented when the Menu button is pressed.
    *   Menu options: Create Button, Edit Button, Settings
    ************************************************************************************************ */
    @IBAction func menuButtonPressed(sender: UIButton)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in }
        alertController.addAction((cancelAction))
        
        // create settings button
        let settingsAction = UIAlertAction(title: "Settings", style: .Default)
        {
            action in
            self.performSegueWithIdentifier("settingsSegue", sender: self)
        }
        //create create button
        let createAction = UIAlertAction(title: "Create button", style: .Default) { (action) -> Void in
            self.createButtonPressed()
        }
        alertController.addAction(createAction)
        
        // create edit button
        let editAction = UIAlertAction(title: "Edit button", style: .Destructive) { (action) -> Void in
            var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.editMode = !appDelegate.editMode
            if(appDelegate.editMode)
            {
                let doneButton = Util().createDoneEditingButton(self)
                self.navBarTitle.leftBarButtonItem = UIBarButtonItem(customView: doneButton)
                self.scanner.stopScan()
                var cells = self.collectionview.visibleCells()
                for(var i = 0; i < cells.count; i++)
                {
                    cells[i].addAnimation(self.startShakingButtons(), forKey: "shake")
                }
                
//                self.navBarTitle.title = self.navBarTitle.title?.stringByAppendingString(" (Edit Mode)")
            }
            else
            {
//                self.navBarTitle.title = self.navBarTitle.title?.stringByReplacingOccurrencesOfString(" (Edit Mode)", withString: "")
                self.doneEditing()
//                self.collectionview.reloadData()
            }
        }
        alertController.addAction(editAction)
        alertController.addAction(settingsAction)
        alertController.popoverPresentationController?.sourceView = sender as UIView
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func doneEditing()
    {
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.editMode = false
        navBarTitle.leftBarButtonItem = nil
        if(!appDelegate.editMode)
        {
            if previousPage != ""
            {
                let backButton = Util().createNavBarBackButton(self, string: previousPage)
                let back = UIBarButtonItem(customView: backButton)
                navBarTitle.leftBarButtonItem = back
                configureEntireView(myCollectionView, pageLink: link, title: "Home", navBarButtons: [backButton])
            }
            else
            {
                configureEntireView(myCollectionView, pageLink: link, title: "Home", navBarButtons: [])
            }
        }

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
    *   Gets called when a user physically presses a button on the screen
    ******************************************************************************************/
    func manuallyPressedButton(performSegue: Bool, toPage: String)
    {
        if toPage == "Notes"
        {
            performSegueWithIdentifier("toList", sender: self)
        }
        else
        {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! CollectionViewBase
            vc.link = toPage
            
            vc.previousPage = link
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func callBackFromModalSaving(data: ButtonModel)
    {
        editOrModifyButton(data)
        configureEntireView(collectionview, pageLink: link, title: navBar, navBarButtons: [menuButton])
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func callBackFromModalDelete()
    {
        configureEntireView(collectionview, pageLink: link, title: navBar, navBarButtons: [menuButton])
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
        
        // check if currently in edit mode, if so we need to update the button
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.editMode)
        {
            coreDataObject.updateButtonWith(buttonTitle, newTitle: title, longDescription: longDescription, image: imagePath, linkedPage: linkedPage)
        }
        else // otherwise we are creating a button
        {
            let (success, tableItems) = coreDataObject.getTables(link)
            if success
            {
                coreDataObject.createInManagedObjectContextTable(title, image: imagePath, longDescription: longDescription, table: link, index: buttons.count, linkedPage: linkedPage)
                
                var buttonObject = ButtonModel(title: title, longDescription: longDescription, imagePath: imagePath, linkedPage: linkedPage)
                buttons.addObject(buttonObject)
            }
        }
        
        collectionview.reloadData()
    }
    
    /******************************************************************************************
    *   Show the create button view
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
                let title = (item as! ButtonCell).buttonLabel.text!
                let image = (item as! ButtonCell).buttonObject!.imagePath
                let longDescription = (item as! ButtonCell).buttonObject!.longDescription
                let link = title.stringByReplacingOccurrencesOfString(" ", withString: "")
                
                coreDataObject.createInManagedObjectContextTable(title, image: image, longDescription: longDescription, table: link, index: counter, linkedPage: "")
                counter++
            }
        }
    }
    
    deinit
    {
        println("Deinit")
        NSNotificationCenter.defaultCenter().removeObserver(foregroundNotification)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func viewWillAppear(animated: Bool)
    {
        // Sets up a notification that tells when this view is opened again after being in the background
        foregroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue())
        {
            [unowned self] notification in
            self.textBox.resignFirstResponder() // deactivate the textfield
            var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if appDelegate.editMode
            {
                var cells = self.collectionview.visibleCells()
                for(var i = 0; i < cells.count; i++)
                {
                    cells[i].addAnimation(self.startShakingButtons(), forKey: "shake")
                }
            }
            self.textBox.becomeFirstResponder() // make the textfield active again
        }
        
        // check if currently in edit mode, if so we need to update the button
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(!appDelegate.editMode)
        {
            if previousPage != ""
            {
                let backButton = Util().createNavBarBackButton(self, string: previousPage)
                let back = UIBarButtonItem(customView: backButton)
                navBarTitle.leftBarButtonItem = back
                configureEntireView(myCollectionView, pageLink: link, title: "Home", navBarButtons: [backButton])
            }
            else
            {
                configureEntireView(myCollectionView, pageLink: link, title: "Home", navBarButtons: [])
            }
        }

        textBox.inputView = UIView()        // textBox is used to get input from bluetooth
        textBox.becomeFirstResponder()
        buttonCell.delegate = self
    }
    
    /******************************************************************************************
    *   This gets called when the back button in the navigation bar is activated. It goes back
    *   one view in the navigation stack
    ******************************************************************************************/
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
        self.collectionview = collectionView //setup(collectionView)
        setLayout()
        self.link = pageLink //setLink(pageLink)
        setTapRecognizer()
        getButtonsFromDB()
        collectionview.reloadData()
        scanner.reloadData(layout.collectionViewContentSize(), numButtons: buttons.count)
        scanner.setupNavBar(navBarButtons)
        configureButtons()
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func setLayout()
    {
        layout = self.collectionview.collectionViewLayout as! LXReorderableCollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func setTapRecognizer()
    {
        self.tapRec = UITapGestureRecognizer()
        tapRec.addTarget( self, action: "tapHandler:")
        tapRec.numberOfTapsRequired = 1
        tapRec.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapRec)
    }
    
    /******************************************************************************************
    *   gets the users preferences for button size and style
    ******************************************************************************************/
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
                let title = buttonDetails.title
                let image = buttonDetails.image
                let longDescription = buttonDetails.longDescription
                let index = buttonDetails.index
                let linkedPage = buttonDetails.linkedPage
                
                // If there really is data, configure the button and add it to the array of buttons
                if(title != "")
                {
                    var buttonObject = ButtonModel(title: title, longDescription: longDescription, imagePath: image, linkedPage: linkedPage)
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
//        println("did layout")
        if !currentlyDragging
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
            
            (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSizeMake(dim, dim)
            
            rowSet.removeAllObjects()
            colSet.removeAllObjects()
            var currItem = 0
            for (currItem = 0; currItem < cellArray.count; currItem++)
            {
                var cell = collectionview.cellForItemAtIndexPath(NSIndexPath(forItem: currItem, inSection: 0)) as! ButtonCell
                // set the proper frame size for the arrow link image. 8 is the margin distance for x and y
                cell.pageLinkImageView.frame = CGRectMake(cell.frame.width - 8 - dim/5, 8, dim/5, dim/5)
                
                rowSet.addObject(cell.frame.origin.y)
                colSet.addObject(cell.frame.origin.x)
            }
            
            scanner.setRowsAndCols(rowSet.count, cols: colSet.count) // Tell the scanner how many rows/cols
        }
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
        let buttonObject = self.buttons[indexPath.item] as! ButtonModel
        var buttonCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ButtonCell
        buttonCell.setup(buttonObject)
        buttonCell.delegate = self
        
        // if the button links to a page, show the arrow link image
        if buttonObject.linkedPage != ""
        {
            buttonCell.pageLinkImageView.hidden = false
        }
        else
        {
            buttonCell.pageLinkImageView.hidden = true
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
                var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
        println("drag")
        fromIndexPath = indexPath
        currentlyDragging = true
    }
    
    /* ***********************************************************************************************************
    *	Gets called when the user ends the dragging of an icon. The starting indexPath is compared with the ending
    *	indexPath. If the same, no action is taken.  If different, the cellArray and button array are refactored
    *********************************************************************************************************** */
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didEndDraggingItemAtIndexPath toIndexPath: NSIndexPath!)
    {
        println("done draging")
        currentlyDragging = false
        if( fromIndexPath != toIndexPath)
        {
            reordered = true

            scanner.cellArray.removeAllObjects()
            cellArray.removeAllObjects()

            var button = self.buttons[fromIndexPath.item] as! UIButton
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
        println("Tap")
        let nextPageLink = scanner.selectionMade(false, inputKey: nil)

        if nextPageLink != ""
        {
            if nextPageLink == "Notes"
            {
                performSegueWithIdentifier("toList", sender: self)
            }
            else
            {
                scanner.selectionMade(true, inputKey:  nil)
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! CollectionViewBase
                vc.link = nextPageLink
                vc.previousPage = link

                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    /* ************************************************************************************************************
    *	When the "Create Button" button is pressed, this configures the current ViewController to retrieve the data
    *	that is entered in the create button form.
    ************************************************************************************************************* */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if segue.identifier == "toList"
        {
            let controller = segue.destinationViewController as! ListViewController
            controller.previousPage = link
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
    * from MainCollectionView
    ******************************************************************************************/
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        println("text change")
        let switchMode = NSUserDefaults.standardUserDefaults().integerForKey("numberOfSwitches")
        
        if switchMode == SWITCHMODE.SINGLE.rawValue
        {
            if( string == " ")
            {
                let nextPageLink = scanner.selectionMade(false, inputKey: nil)
                
                if nextPageLink != ""
                {
                    if nextPageLink == "Notes"
                    {
                        performSegueWithIdentifier("toList", sender: self)
                    }
                    else
                    {
                        scanner.selectionMade(true, inputKey: nil)
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! CollectionViewBase
                        vc.link = nextPageLink
                        vc.previousPage = link
                        navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        else if( switchMode == SWITCHMODE.DOUBLE.rawValue)
        {            
            if( string == " ")
            {
                let nextPageLink = scanner.selectionMade(false, inputKey: "space")

            }
            else if string == "\n"
            {
                let nextPageLink = scanner.selectionMade(false, inputKey: "enter")

                if nextPageLink != ""
                {
                    if nextPageLink == "Notes"
                    {
                        performSegueWithIdentifier("toList", sender: self)
                    }
                    else
                    {
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! CollectionViewBase
                        vc.link = nextPageLink
                        vc.previousPage = link
                        navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }

            
        }
        
        return false
    }

    
    
    
}