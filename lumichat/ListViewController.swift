//
//  ListViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 1/27/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, KeyboardDelegate, TableViewEditDelegate
{
    var data:NSMutableArray?
    @IBOutlet weak var bluetoothTextField: UITextField!
    @IBOutlet weak var phraseTextView: UITextView!
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
        
        phraseTextView.layer.cornerRadius = 8
        phraseTextView.layer.borderWidth = 0.4
        phraseTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        phraseTextView.scrollEnabled = false
    }
    
    override func viewWillAppear(animated: Bool)
    {
        tableScanner.initialization([backButton!, editButton!, phraseTextView])
    }
    
    func handleBack()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func textViewDidBeginEditing(textView: UITextView)
    {
        // check if the active textfield is the phraseField
        if textView === phraseTextView
        {
            tableScanner.timer.invalidate()
            keyboardView = Keyboard()
            phraseTextView.resignFirstResponder()
            keyboardView!.delegate = self
            currentScanner = "Keyboard"
            keyboardScanner.initialization(keyboardView!.keyCollection)
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
        phraseTextView.text = phraseTextView.text + key
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func deleteWasPressed()
    {
        let text = phraseTextView.text
        if text != ""
        {
            phraseTextView.text = phraseTextView.text.substringToIndex(text.endIndex.predecessor())
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func spaceWasPressed()
    {
        phraseTextView.text = phraseTextView.text + " "
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:TableViewCellEditView?
        if cell == nil
        {
            tableView.registerNib(UINib(nibName: "TableViewCellEditView", bundle: nil), forCellReuseIdentifier: "phraseCell")
            cell = tableView.dequeueReusableCellWithIdentifier("phraseCell") as? TableViewCellEditView
            cell?.delegate = self
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        (cell as! TableViewCellEditView).phraseLabel.text = data![indexPath.row] as? String
        (cell as! TableViewCellEditView).indexPath = indexPath
        tableScanner.addCell(cell as! TableViewCellEditView)
        if tableScanner.editMode
        {
            (cell as! TableViewCellEditView).setEditing()
        }
        else
        {
            (cell as! TableViewCellEditView).doneEditing()
        }
    }
    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCellEditView
        
        CoreDataController().incrementPressCountForPhrase(cell.phraseLabel.text!)
        Util().speak( cell.phraseLabel.text! )
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
    * TABLE VIEW CELL EDIT VIEW DELEGATE METHODS
    ******************************************************************************************/
    func tableViewEditViewcancelPressed()
    {
        println("Cancel")
    }
    
    func tableViewEditViewdeletePressed(indexPath: NSIndexPath)
    {
        CoreDataController().deletePhraseWithTitle(self.data![indexPath.row] as! String) // remove from database
        self.data?.removeObjectAtIndex(indexPath.row) // remove from datasource
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic) // update view
        tableScanner.reloadSource([backButton!, editButton!,phraseTextView]) // reiniitialize the scanner
        tableView.reloadData()
    }

    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @IBAction func saveButtonPressed(sender: AnyObject)
    {
        currentScanner = "Table"
        keyboardScanner.timer.invalidate()
        keyboardView?.removeFromSuperview()
        
        phraseTextView.resignFirstResponder()
        if phraseTextView.text != ""
        {
            CoreDataController().createInManagedObjectContextPhrase(phraseTextView.text)
            data = CoreDataController().getPhrases()
            phraseTextView.text = ""
            phraseTextView.resignFirstResponder()
            tableScanner.reloadSource([backButton!, editButton!,phraseTextView]) // reiniitialize the scanner
            tableView.reloadData()
        }
    }
    
    
    func editButtonPressed()
    {
        if editButton?.titleForState(.Normal) == "Edit"
        {
            tableScanner.editMode = true
            editButton?.setTitle("Done Editing", forState: .Normal)
            editButton?.frame = CGRectMake(0, 0, 100, 30)
            let visibleCells = tableView.visibleCells() as! [TableViewCellEditView]
            let indexPaths = tableView.indexPathsForVisibleRows() as! [NSIndexPath]
            for(var i = 0; i < visibleCells.count; i++)
            {
                visibleCells[i].setEditing()
            }
        }
        else
        {
            tableScanner.editMode = false
            editButton?.setTitle("Edit", forState: .Normal)
            editButton?.frame = CGRectMake(0, 0, 80, 30)
            let visibleCells = tableView.visibleCells() as! [TableViewCellEditView]
            
            for(var i = 0; i < visibleCells.count; i++)
            {
                visibleCells[i].doneEditing()
            }
        }
    }
    
}