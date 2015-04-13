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
    var editButton:UIButton?
    var previousPage = ""
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        tableScanner.timer.invalidate()
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func viewDidLoad()
    {
        self.title = "Notes"
        backButton = Util().createNavBarBackButton(self, string: previousPage)
        let back = UIBarButtonItem(customView: backButton!)
        navigationItem.leftBarButtonItem = back
        
        editButton = Util().createEditButton(self)
        let edit = UIBarButtonItem(customView: editButton!)
        navigationItem.rightBarButtonItem = edit

        data = CoreDataController().getPhrases()
        bluetoothTextField.inputView = UIView()        // textBox is used to get input from bluetooth
        bluetoothTextField.becomeFirstResponder()
//        tableView.editing = true
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
                tableScanner.selectionMade(false, inputKey: "space")
            }
            else
            {
                keyboardScanner.selectionMade(false, inputKey: "space")
            }
        }
        else if( string == "\n")
        {
            println("enter")
            if currentScanner == "Table"
            {
                tableScanner.selectionMade(false, inputKey: "enter")
            }
            else
            {
                keyboardScanner.selectionMade(false, inputKey: "enter")
            }
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
        var cell = tableView.dequeueReusableCellWithIdentifier("listCell") as! UITableViewCell
        cell.textLabel?.text = data![indexPath.row] as? String
        tableScanner.addCell(cell)
        return cell
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let phrase = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
        CoreDataController().incrementPressCountForPhrase(phrase!)
        Util().speak( cell!.textLabel!.text! )

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
    *   Configure the edit and delete button for the tableviewcells
    ******************************************************************************************/
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        var deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
            
            tableView.editing = false
            CoreDataController().deletePhraseWithTitle(self.data![indexPath.row] as! String) // remove from database
            self.data?.removeObjectAtIndex(indexPath.row) // remove from datasource
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic) // update view
        }
        
        var editAction = UITableViewRowAction(style: .Default, title: "Edit") { (action, indexPath) -> Void in
            tableView.editing = false
        }
        editAction.backgroundColor = UIColor.greenColor()
        
        return [deleteAction]//, editAction]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
//    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
//        return tableView.editing ? UITableViewCellEditingStyle.None: UITableViewCellEditingStyle.Delete
//    }
    
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
            tableScanner.initialization([backButton!,phraseTextField]) // reiniitialize the scanner
            tableView.reloadData()
        }
//        tableScanner.setScanMode()
    }
    
    @IBAction func editButtonPress(sender: AnyObject)
    {
        println("edit")
        tableView.editing = true
    }
    
    func editButtonPressed()
    {
        println("edit")
        tableView.editing = true
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
        keyboardScanner.selectionMade(true, inputKey: nil)
//        bluetoothTextField.becomeFirstResponder()
    }
    
}