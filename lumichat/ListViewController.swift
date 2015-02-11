//
//  ListViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 1/27/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, KeyboardDelegate
{
    var data:NSArray?
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    private var tableScanner = TableViewScanner.sharedInstance
    private var keyboardView:Keyboard?
    private var keyboardScanner = KeyboardScanner.sharedInstance
    var tapRec: UITapGestureRecognizer!

    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func viewDidLoad()
    {
        self.title = "Notes"
        data = CoreDataController().getPhrases()
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        keyboardView = Keyboard()
        keyboardView!.delegate = self
        keyboardScanner.initialization(keyboardView!.keyCollection)
        setTapRecognizer()

        view.addSubview(keyboardView!)
    }
    
    func keyWasPressed(key: String)
    {
        phraseTextField.text = phraseTextField.text + key
    }
    
    func deleteWasPressed()
    {
        let text = phraseTextField.text
        if text != ""
        {
            phraseTextField.text = phraseTextField.text.substringToIndex(text.endIndex.predecessor())
        }
    }
    
    func spaceWasPressed()
    {
        phraseTextField.text = phraseTextField.text + " "
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("listCell") as UITableViewCell
        cell.textLabel?.text = data![indexPath.row] as? String
        return cell
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let phrase = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
        CoreDataController().incrementPressCountForPhrase(phrase!)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data!.count
    }
 
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Saved phrases"
    }
    /******************************************************************************************
    *
    ******************************************************************************************/
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @IBAction func saveButtonPressed(sender: AnyObject)
    {
        keyboardView?.removeFromSuperview()
        keyboardView?.userInteractionEnabled = false
        self.view.removeGestureRecognizer(tapRec)
        phraseTextField.resignFirstResponder()
        if phraseTextField.text != ""
        {
            CoreDataController().createInManagedObjectContextPhrase(phraseTextField.text)
            data = CoreDataController().getPhrases()
            phraseTextField.text = ""
            phraseTextField.placeholder = "Type a new phrase..."
            phraseTextField.resignFirstResponder()
            tableView.reloadData()
        }
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
    
    /* ******************************************************************************************
    *
    ******************************************************************************************** */
    func tapHandler(gesture: UITapGestureRecognizer)
    {
        keyboardScanner.selectionMade(true)
    }
    
}