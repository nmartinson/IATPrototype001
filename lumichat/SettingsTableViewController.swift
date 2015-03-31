//
//  SettingsTableViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 3/17/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var borderWidthLabel: UILabel!
    @IBOutlet weak var scanRateValue: UILabel!
    @IBOutlet weak var scanRateSlider: UISlider!
    @IBOutlet weak var scanModeSegment: UISegmentedControl!
    @IBOutlet weak var styleSegment: UISegmentedControl!
    @IBOutlet weak var borderWidthSlider: UISlider!
    @IBOutlet weak var colorPicker: UIPickerView!
    @IBOutlet weak var exportDatabaseButton: UIButton!
    @IBOutlet weak var numberOfSwitchesSegment: UISegmentedControl!
    var defaults = NSUserDefaults.standardUserDefaults()
    var colorNames = [ "Black", "Blue", "Red", "Yellow", "Orange", "Green"]	// Displayed in the color picker

    
    /* *******************************************************************************************************
    *	Gets called when the view finishes loading.
    *	Goes through all the settings Data and sets the UI elements to the previously selected selectings
    *	by the user.
    ******************************************************************************************************* */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let scanValue: AnyObject! = defaults.objectForKey("scanRate")
        if(scanValue != nil)
        {
            self.scanRateValue.text = "\(scanValue.stringValue) seconds"
            self.scanRateSlider.value = scanValue.floatValue
        }

        let style = defaults.integerForKey("buttonStyle")
        self.styleSegment.selectedSegmentIndex = style

        let borderColor = defaults.integerForKey("buttonBorderColor")
        self.colorPicker.selectRow(borderColor, inComponent: 0, animated: true)

        let borderWidth = defaults.integerForKey("buttonBorderWidth")
        self.borderWidthSlider.value = Float(borderWidth)
        self.borderWidthLabel.text = "\(borderWidth) pixels"

        let scanMode = defaults.integerForKey("scanMode")
        self.scanModeSegment.selectedSegmentIndex = scanMode
        
        let numberOfSwitches = defaults.integerForKey("numberOfSwitches")
        self.numberOfSwitchesSegment.selectedSegmentIndex = numberOfSwitches
    }
    
    
    /* *******************************************************************************************************
    *
    ******************************************************************************************************* */
    @IBAction func exportDatabaseButtonPressed(sender: AnyObject)
    {
        let mailCoposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail()
        {
            self.presentViewController(mailCoposeViewController, animated: true, completion: nil)
        }
    }
    
    /* *******************************************************************************************************
    *
    ******************************************************************************************************* */
    func configuredMailComposeViewController() -> MFMailComposeViewController
    {
        var zip = Zipping()
        zip.zipDirectory("images/user", destination: "daterbase.zip")
        var filePath = zip.getFilePath("daterbase.zip")
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject("User database from Lumichat")
        
        // check if file exists
        if( NSFileManager.defaultManager().fileExistsAtPath(filePath) )
        {
            var data = NSData(contentsOfMappedFile: filePath)
            mailComposerVC.addAttachmentData(data, mimeType: "application/zip", fileName: "file.zip")
        }
        
        
        return mailComposerVC
    }
    
    /* *******************************************************************************************************
    *
    ******************************************************************************************************* */
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError)
    {
        Util().deleteFile("daterbase.zip")
        controller.dismissViewControllerAnimated(true, completion:nil)
    }
    
    
    /* *******************************************************************************************************
    *	Gets called when a different button style is selected.
    *	Stores an integer index in the settings Data referencing the segment selected.
    ******************************************************************************************************* */
    @IBAction func styleModeChanged(sender: AnyObject)
    {
        var index = styleSegment.selectedSegmentIndex
        defaults.setInteger(index, forKey: "buttonStyle")
    }
    
    /* *******************************************************************************************************
    *	Gets called when the scan rate slider has changed value.
    *	Stores a float value for the slider in the settings Data and updates the screen with the new value.
    ******************************************************************************************************* */
    @IBAction func scanRateSliderChanged(sender: AnyObject)
    {
        var value = NSString(format: "%.1f", scanRateSlider.value)
        self.scanRateValue.text = "\(value) seconds"
        
        // store slider value in the defaults list
        defaults.setFloat(value.floatValue, forKey: "scanRate")
    }
    
    /* *******************************************************************************************************
    *	Gets called when the border width slider has changed values.
    *	Stores an integer value for the slider in the settings Data and updates the screen with the new value.
    ******************************************************************************************************* */
    @IBAction func borderWidthSliderChanged(sender: AnyObject)
    {
        var value: Int = Int(borderWidthSlider.value)
        self.borderWidthLabel.text = "\(value) pixels"
        defaults.setInteger(value, forKey: "buttonBorderWidth")
//        imagePreview.layer.borderWidth = CGFloat(value)
    }
    
    /* *******************************************************************************************************
    *	Gets called when a different scan mode is selected.
    *	Stores an integer index in the settings Data referencing the segment selected.
    ******************************************************************************************************* */
    @IBAction func scanModeChanged(sender: AnyObject)
    {
        var index = scanModeSegment.selectedSegmentIndex
        defaults.setInteger(index, forKey: "scanMode")
    }
    
    /* *******************************************************************************************************
    *	Gets called automatically
    ******************************************************************************************************* */
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int
    {
        return 1;
    }
    
    /* *******************************************************************************************************
    *	Gets called automatically
    *	Returns number of rows in the picker view
    ******************************************************************************************************* */
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int
    {
        return Constants.colorNames.count;
    }
    
    /* *******************************************************************************************************
    *	Gets called automatically
    *	Returns the string that should be displayed in the picker view at a specific row
    ******************************************************************************************************* */
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String
    {
        return Constants.getColorName(row)
    }
    
    /* *******************************************************************************************************
    *	Gets called automatically
    *	When a row gets selected, that row number is stored in the settings Data with a specific key for 
    *	accessing it. This data is used for persistently showing which item is selected and for using settings.
    ******************************************************************************************************* */
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int)
    {
//        NSUserDefaults.standardUserDefaults().setInteger( row, forKey: "buttonBorderColor")
//        imagePreview.layer.borderColor = Constants.getColor(row)
    }
    
    @IBAction func numberOfSwitchesChanged(sender: UISegmentedControl)
    {
        let index = sender.selectedSegmentIndex
        defaults.setInteger(index, forKey: "numberOfSwitches")
    }
    
}