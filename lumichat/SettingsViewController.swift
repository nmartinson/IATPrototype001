//  SettingsViewController.swift
//  DatabaseTable
//
//  Created by Nick Martinson on 8/11/14.
//  Copyright (c) 2014 BAapps. All rights reserved.
//
//	This view controller is repsonsible for the Settings view. It allows users to change app wide settings.
//	The data is stored in the NSDefaults and accessible app wide.

import Foundation
import UIKit
import MessageUI

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate
{
	@IBOutlet weak var buttonSizeSegment: UISegmentedControl!	// segment for selecting buton size
	@IBOutlet weak var borderWidthLabel: UILabel!	// displays border width
	@IBOutlet weak var borderWidthSlider: UISlider!	// slider for selecting border width
	@IBOutlet weak var scanRate: UISlider!	// slider for selecting scan rate
	@IBOutlet weak var scanRateValue: UILabel!	// displays value of scan rate slider
	@IBOutlet weak var scanModeSegment: UISegmentedControl!	// segment for selecting scan mode
	@IBOutlet weak var styleSegment: UISegmentedControl!	// segment for selecting button style
	@IBOutlet weak var colorPicker: UIPickerView!	// scroll for picking color
    @IBOutlet weak var exportDatabase: UIButton!
	var colorNames = [ "Black", "Blue", "Red", "Yellow", "Orange", "Green"]	// Displayed in the color picker
	
	var imagePreview: UIImageView!
	
	
	/* *******************************************************************************************************
	*	Gets called when the view finishes loading.
	*	Goes through all the settings Data and sets the UI elements to the previously selected selectings
	*	by the user.
	******************************************************************************************************* */
	override func viewDidLoad()
	{
		super.viewDidLoad()
		var defaults = NSUserDefaults.standardUserDefaults()
		
		var scanValue: AnyObject! = defaults.objectForKey("scanRate")
		if(scanValue != nil)
		{
			self.scanRateValue.text = "\(scanValue.stringValue) seconds"
			self.scanRate.value = scanValue.floatValue
		}
		var style = defaults.integerForKey("buttonStyle")
//		if(style != nil)
//		{
			self.styleSegment.selectedSegmentIndex = style
//		}
		var borderColor = defaults.integerForKey("buttonBorderColor")
//		if( borderColor != nil)
//		{
			self.colorPicker.selectRow(borderColor, inComponent: 0, animated: true)
//		}
		var borderWidth = defaults.integerForKey("buttonBorderWidth")
//		if( borderWidth != nil)
//		{
			self.borderWidthSlider.value = Float(borderWidth)
			self.borderWidthLabel.text = "\(borderWidth) pixels"
//		}
		var buttonSize = defaults.integerForKey("buttonSize")
//		if( buttonSize != nil)
//		{
			self.buttonSizeSegment.selectedSegmentIndex = buttonSize
		
//		}
		var scanMode = defaults.integerForKey("scanMode")
//		if( scanMode != nil)
//		{
			self.scanModeSegment.selectedSegmentIndex = scanMode
//		}
		
		
		var image = UIImage(named: "buttonTest.jpg")
		self.imagePreview = UIImageView()
		
        self.imagePreview.frame = CGRectMake(300, 700, Constants.getCellSize(buttonSize, numberOfButtons: 1).width, Constants.getCellSize(buttonSize, numberOfButtons: 1).height)
		self.imagePreview.image = image
		self.view.addSubview(imagePreview)

		
		imagePreview.frame.size = Constants.getCellSize(buttonSize, numberOfButtons: 1)
		imagePreview.layer.borderColor = Constants.getColor(borderColor)
		imagePreview.layer.borderWidth = CGFloat(borderWidth)

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
	*	Gets called when the button size is changed
	*	Stores an integer index in the settings Data referencing the segment selected.
	******************************************************************************************************* */
	@IBAction func buttonSizeSegmentChanged(sender: AnyObject)
	{
		var index = buttonSizeSegment.selectedSegmentIndex
		var defaults = NSUserDefaults.standardUserDefaults()
		defaults.setInteger(index, forKey: "buttonSize")
		imagePreview.frame.size = Constants.getCellSize(index, numberOfButtons: 1)
	}
	
	/* *******************************************************************************************************
	*	Gets called when a different button style is selected.
	*	Stores an integer index in the settings Data referencing the segment selected.
	******************************************************************************************************* */
	@IBAction func styleModeChanged(sender: AnyObject)
	{
		var index = styleSegment.selectedSegmentIndex
		var defaults = NSUserDefaults.standardUserDefaults()
		defaults.setInteger(index, forKey: "buttonStyle")
	}
	
	/* *******************************************************************************************************
	*	Gets called when the scan rate slider has changed value.
	*	Stores a float value for the slider in the settings Data and updates the screen with the new value.
	******************************************************************************************************* */
	@IBAction func scanRateSliderChanged(sender: AnyObject)
	{
		var value = NSString(format: "%.1f", scanRate.value)
		self.scanRateValue.text = "\(value) seconds"
		
		// store slider value in the defaults list
		var defaults = NSUserDefaults.standardUserDefaults()
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
		NSUserDefaults.standardUserDefaults().setInteger(value, forKey: "buttonBorderWidth")
		imagePreview.layer.borderWidth = CGFloat(value)
	}
	
	/* *******************************************************************************************************
	*	Gets called when a different scan mode is selected.
	*	Stores an integer index in the settings Data referencing the segment selected.
	******************************************************************************************************* */
	@IBAction func scanModeChanged(sender: AnyObject)
	{
		var index = scanModeSegment.selectedSegmentIndex
		var defaults = NSUserDefaults.standardUserDefaults()
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
		NSUserDefaults.standardUserDefaults().setInteger( row, forKey: "buttonBorderColor")
		imagePreview.layer.borderColor = Constants.getColor(row)
	}
}