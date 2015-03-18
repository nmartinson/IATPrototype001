//
//  CreateButtonTableViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 3/17/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

class CreateButtonTableViewController: ModifyButtonTableViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    @IBOutlet weak var pageLinkCell: UITableViewCell!
    @IBOutlet weak var linkSegment: UISegmentedControl!
    var hidePageLinkCell = true
 
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    
    @IBAction func linkSegmentChanged(sender: UISegmentedControl)
    {
        hidePageLinkCell = !hidePageLinkCell
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath == NSIndexPath(forRow: 3, inSection: 0)
        {
            return 115
        }
        else if indexPath == NSIndexPath(forRow: 5, inSection: 0)
        {
            if hidePageLinkCell
            {
                pageLinkCell.hidden = true
                return 214
            }
            pageLinkCell.hidden = false
            return 214
        }
        return 44
    }
    
    
    /* *******************************************************************************************************
    *	Gets called automatically
    *	Returns number of rows in the picker view
    ******************************************************************************************************* */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return 5
    }


    /* *******************************************************************************************************
    *	Gets called automatically
    *	Returns the string that should be displayed in the picker view at a specific row
    ******************************************************************************************************* */
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String
    {
        return "HO"
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
}