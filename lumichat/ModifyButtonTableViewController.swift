//
//  ModifyButtonTableViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 3/17/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

protocol ModifyButtonDelegate
{
    func callBackFromModalSaving(data: ButtonModel)
    func callBackFromModalDelete()
}


class ModifyButtonTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var pagePicker: UIPickerView!
    @IBOutlet weak var textDescription: UITextView!
    @IBOutlet var pictureButton: UIView!
    @IBOutlet weak var createNewPageField: UITextField!
    @IBOutlet weak var errorField: UILabel!		// Where the error message is displayed
    @IBOutlet weak var buttonTitleField: UITextField!	// Textfield that holds the new button title
    var capturedImage: UIImage!
    @IBOutlet weak var buttonImage: UIImageView!
    @IBOutlet weak var pageLinkCell: UITableViewCell!
    @IBOutlet weak var createPageCell: UITableViewCell!
    @IBOutlet weak var linkSegment: UISegmentedControl!
    var hidePageLinkCell = true
    var pages:[String] = []
    var delegate: ModifyButtonDelegate?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let (success, pagesArray) = CoreDataController().getPages()
        if success
        {
            pages = pagesArray!
        }
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!)
    {
        //  let selectedImage : UIImage = image
        self.capturedImage = image
        buttonImage.image = self.capturedImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* ************************************************************************************************
    *	Compress image size
    ************************************************************************************************ */
    func imageWithImage(image: UIImage) -> UIImage
    {
        var actualHeight = image.size.height;
        var actualWidth = image.size.width;
        var imgRatio = actualWidth/actualHeight;
        var maxRatio:CGFloat = 320.0/480.0;
        
        if(imgRatio != maxRatio){
            if(imgRatio < maxRatio){
                imgRatio = 480.0 / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = 480.0;
            }
            else{
                imgRatio = 320.0 / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = 320.0;
            }
        }
        var newSize = CGSizeMake(actualWidth, actualHeight)
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0,0, newSize.width, newSize.height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /* ************************************************************************************************
    *	Create a new directory to store the images in
    ************************************************************************************************ */
    func createDirectory(directory: String) -> String
    {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = documentDirectory.stringByAppendingPathComponent(directory) // append images to the directory string
        
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
        return path
    }
    
    /* *******************************************************************************************************
    *	Saves image to a new 'image' directory in the Documents directory.
    ******************************************************************************************************* */
    func saveImage(image: UIImage?, title: String) -> String
    {
        var path = createDirectory("images/user")
        
        if (image != nil)
        {
            var newImage = imageWithImage(image!)
            path = path.stringByAppendingString("/\(title).jpg") // append the image name with .jpg extension
            let data = UIImageJPEGRepresentation(newImage, 1) //create data from jpeg
            
            NSFileManager.defaultManager().createFileAtPath(path, contents: data, attributes: nil) // write data to file...content was data
            
            let imagePath = "images/user/\(title).jpg" // return only the path that is appended to the 'documents' path
            return imagePath
        }
        else
        {
            return "images/stock/buttonTest.jpg"
        }
    }
    
    /* *******************************************************************************************************
    *	Gets called when the save button is pressed. Checks to see if the button title field is not empty and if
    *	it isn't, the data is passed back to the previous view controller, where it is put in the DB. If it
    *	is empty, an error message is printed.
    ******************************************************************************************************* */
    @IBAction func saveButton(sender: AnyObject)
    {
        // dont link a page
        var linkedPage = ""
        if linkSegment.selectedSegmentIndex == 1
        {
            let pickerIndex = pagePicker.selectedRowInComponent(0)
            linkedPage = pages[pickerIndex]
        }
        
        let imageTitle = "\(Constants.getTime())-\(buttonTitleField.text)"
        let title = buttonTitleField.text as String
        let longDescription = textDescription.text as String
        var path = ""
        
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.editMode)
        {
            if capturedImage != nil
            {
                path = saveImage(self.capturedImage, title: imageTitle)
            }
            let buttonData = ButtonModel(title: title, longDescription: longDescription, imagePath: path, linkedPage: linkedPage)
            self.delegate?.callBackFromModalSaving(buttonData)
            self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        }
        else if( buttonTitleField.text != "")
        {
            path = saveImage(self.capturedImage, title: imageTitle)
            let buttonData = ButtonModel(title: title, longDescription: longDescription, imagePath: path, linkedPage: linkedPage)

            self.delegate?.callBackFromModalSaving(buttonData)
            self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        }
        else
        {
            errorField.text = "Missing data, please finish form"
        }
    }
    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
    /******************************************************************************************
    *   Gets called when the
    ******************************************************************************************/
    @IBAction func linkSegmentChanged(sender: UISegmentedControl)
    {
        hidePageLinkCell = !hidePageLinkCell
        tableView.reloadData()
    }
    
    /******************************************************************************************
    *   This sets the height of the cells
    *   hidePageCell: boolean that determines whether to show the create page/select page views
    ******************************************************************************************/
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
                createPageCell.hidden = true
            }
            else
            {
                createPageCell.hidden = false
            }
        }
        else if indexPath == NSIndexPath(forRow: 6, inSection: 0)
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
    
    
    /******************************************************************************************
    *   Gets called when the create new page button is pressed
    *   Checks that the input isn't null, then create a new page and reload the page picker 
    *   view to show the new page.
    ******************************************************************************************/
    @IBAction func createNewPageButtonPressed(sender: UIButton)
    {
        let newPage = createNewPageField.text
        if newPage != "" || newPage != " "
        {
            let pageStr = newPage.stringByReplacingOccurrencesOfString(" ", withString: "")
            CoreDataController().createInManagedObjectContextPage(pageStr)
            let (success, pagesArray) = CoreDataController().getPages()
            if success
            {
                pages = pagesArray!
            }
            pagePicker.reloadAllComponents()
            createNewPageField.text = ""
        }
    }
    
    
    /* *******************************************************************************************************
    *	Gets called automatically
    *	Returns number of rows in the picker view
    ******************************************************************************************************* */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pages.count
    }
    
    
    /* *******************************************************************************************************
    *	Gets called automatically
    *	Returns the string that should be displayed in the picker view at a specific row
    ******************************************************************************************************* */
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String
    {
        return pages[row]
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
}