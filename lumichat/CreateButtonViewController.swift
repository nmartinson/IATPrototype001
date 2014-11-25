//  CreateButtonViewController.swift
//  DatabaseTable
//
//  Created by Nick Martinson on 8/12/14.
//  Copyright (c) 2014 BAapps. All rights reserved.
//
//	This view controller is responsible for the create button view. It takes input from
//	the user and passes it back to the previous view to store in the DB.

import Foundation
import UIKit
import MobileCoreServices

class CreateButtonViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var textDescription: UITextView!
	@IBOutlet var pictureButton: UIView!
	@IBOutlet weak var errorField: UILabel!		// Where the error message is displayed
	@IBOutlet weak var buttonTitleField: UITextField!	// Textfield that holds the new button title
    var availableData: ((data:[String:NSObject]) -> () )?	// used for passing data back to previous view controller
	var capturedImage: UIImage!
	@IBOutlet weak var buttonImage: UIImageView!
	var data = ["title":"", "description":"", "path":"", "image":UIImage()]
	
	override func viewDidLoad()
    {
		super.viewDidLoad()
        textDescription.layer.cornerRadius = 8
        textDescription.layer.borderWidth = 0.4
        textDescription.layer.borderColor = UIColor.lightGrayColor().CGColor
	}
	
	/* *******************************************************************************************************
	*	Gets called when the cancel button is pressed on the "Create Button" form. Dismisses modal view.
	******************************************************************************************************* */
	@IBAction func cancelButton(sender: AnyObject)
	{
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
	@IBAction func takePhotoPressed(sender: AnyObject)
	{
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
		{
			var imag = UIImagePickerController()
			imag.delegate = self
			imag.sourceType = UIImagePickerControllerSourceType.Camera
			let type = kUTTypeImage
			let types = [String(type)]
			imag.mediaTypes = types
			imag.allowsEditing = false
			
			self.presentViewController(imag, animated: true, completion: nil)
		}
	}
	
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
	func imagePickerController(picker: UIImagePickerController!,didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!)
    {
		//  let selectedImage : UIImage = image
		self.capturedImage = image
		buttonImage.image = self.capturedImage
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
//	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//		picker.dismissViewControllerAnimated(true, completion: nil)
//	}
	
	
    /* ************************************************************************************************
    *	Gets called when a segue is about to take place going back to the collection view
    *   Passes the new button data back to the LXCollectionViewController
    ************************************************************************************************ */
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if segue.identifier == "fromCreate"
		{
			let LXController = segue.destinationViewController as LXCollectionViewController1
            data["title"] = buttonTitleField.text as String
            data["description"] = textDescription.text as String
            
			if( self.capturedImage != nil)
			{
				data["image"] = self.capturedImage as UIImage
                var path = saveImage(self.capturedImage, title: data["title"] as String)
                data["path"] = path as String
			}
            
            self.availableData?(data: data)
            self.dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
    
    /* *******************************************************************************************************
    *	Saves image to a new 'image' directory in the Documents directory.
    ******************************************************************************************************* */
	func saveImage(image: UIImage?, title: String) -> String
	{
		if (image != nil)
		{
 
			let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
			var path = documentDirectory.stringByAppendingPathComponent("images") // append images to the directory string
            
            if(!NSFileManager.defaultManager().fileExistsAtPath(path))
            {
                var error:NSError?
                if(!NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: &error)) // create new images directory
                {
                    if (error != nil)
                    {
                        println("Create directory error \(error)")
                    }
                }
            }
            
            path = path.stringByAppendingString("/\(title).jpg") // append the image name with .jpg extension
			let data = UIImageJPEGRepresentation(image, 1) //create data from jpeg
            NSFileManager.defaultManager().createFileAtPath(path, contents: data, attributes: nil) // write data to file
            return path
		}
		return ""
	}
	
	/* *******************************************************************************************************
	*	Gets called when the save button is pressed. Checks to see if the button title field is not empty and if
	*	it isn't, the data is passed back to the previous view controller, where it is put in the DB. If it
	*	is empty, an error message is printed.
	******************************************************************************************************* */
	@IBAction func saveButton(sender: AnyObject)
	{
		if( buttonTitleField.text != "")
		{
			performSegueWithIdentifier("fromCreate", sender: self)
		}
		else
		{
			errorField.text = "Missing data, please finish form"
		}
	}
	
}