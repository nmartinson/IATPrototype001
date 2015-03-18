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
    var data:NSMutableArray?
    @IBOutlet weak var bluetoothTextField: UITextField!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    private var tableScanner = TableViewScanner.sharedInstance
    private var keyboardView:Keyboard?
    private var keyboardScanner = KeyboardScanner.sharedInstance
    var tapRec: UITapGestureRecognizer!
    private var currentScanner = "Table"
    var backButton:UIButton?
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func viewDidLoad()
    {
        self.title = "Notes"
        data = CoreDataController().getPhrases()
        bluetoothTextField.inputView = UIView()        // textBox is used to get input from bluetooth
        bluetoothTextField.becomeFirstResponder()
        
        backButton = Util().createNavBarBackButton(self)
        let back = UIBarButtonItem(customView: backButton!)
        navigationItem.leftBarButtonItem = back
    }
    
    override func viewWillAppear(animated: Bool)
    {
        tableScanner.initialization([backButton!, phraseTextField])
    }
    
    func handleBack()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func textFieldDidBeginEditing(textField: UITextField)
    {
        // check if the active textfield is the phraseField
        if textField === phraseTextField
        {
            tableScanner.timer.invalidate()
            keyboardView = Keyboard()
            phraseTextField.resignFirstResponder()
            keyboardView!.delegate = self
            currentScanner = "Keyboard"
            keyboardScanner.initialization(keyboardView!.keyCollection)
            setTapRecognizer()
            view.addSubview(keyboardView!)
            bluetoothTextField.becomeFirstResponder()
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if( string == " ")
        {
            if currentScanner == "Table"
            {
                tableScanner.selectionMade(false)
            }
            else
            {
                keyboardScanner.selectionMade(false)
            }
//            if( tableScanner.secondStageOfSelection == false)
//            {
//                let title = buttons[tableScanner.index].titleForState(.Normal)!
//                if title == "Notes"
//                {
//                    performSegueWithIdentifier("toList", sender: self)
//                }
//                else
//                {
//                    performSegueWithIdentifier("showDetail", sender: self)
//                }
//            }
        }
        else if( string == "\n")
        {
            println("new line")
        }
        
        return false
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func saveWasPressed()
    {
        saveButtonPressed(self)
        
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func keyWasPressed(key: String)
    {
        phraseTextField.text = phraseTextField.text + key
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func deleteWasPressed()
    {
        let text = phraseTextField.text
        if text != ""
        {
            phraseTextField.text = phraseTextField.text.substringToIndex(text.endIndex.predecessor())
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
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
        tableScanner.addCell(cell)
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
        currentScanner = "Table"
        keyboardScanner.timer.invalidate()
        keyboardView?.removeFromSuperview()
        self.view.removeGestureRecognizer(tapRec)
        
        phraseTextField.resignFirstResponder()
        if phraseTextField.text != ""
        {
            CoreDataController().createInManagedObjectContextPhrase(phraseTextField.text)
            data = CoreDataController().getPhrases()
            phraseTextField.text = ""
            phraseTextField.placeholder = "Type a new phrase..."
            phraseTextField.resignFirstResponder()
            tableScanner.removeAllItemsFromDataSource()
            tableView.reloadData()
        }
        tableScanner.setScanMode()
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
//        bluetoothTextField.becomeFirstResponder()
    }
    
}