//
//  MainViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 11/1/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

class MainViewController : CollectionViewBase
{
    @IBOutlet var mycollectionview: UICollectionView!

    override func viewWillAppear(animated: Bool)
    {
        setup(mycollectionview)
        setLayout()
        configureButtons()
        collectionview.reloadData()
        scanner.reloadData(layout.collectionViewContentSize())
    }
    
    override func viewDidLoad()
    {
        buttons.removeAllObjects()
        cellArray.removeAllObjects()

        setTapRecognizer()
        setLink("categories")
        getButtonsFromDB()
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
            detailsViewController.pageLink = title.lowercaseString
        }
    }
    
    
    /* ************************************************************************************************
    *	This is
    ************************************************************************************************ */
    override func tapHandler(gesture: UITapGestureRecognizer)
    {
        scanner.selectionMade(false)
        if( scanner.secondStageOfSelection == false)
        {
            performSegueWithIdentifier("showDetail", sender: self)
        }
    }
}