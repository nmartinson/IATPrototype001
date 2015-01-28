//
//  ListViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 1/27/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var data:NSArray?
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func viewDidLoad()
    {
        self.title = "Notes"
        data = CoreDataController().getPhrases()
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
        CoreDataController().createInManagedObjectContextPhrase(phraseTextField.text)
        
        data = CoreDataController().getPhrases()
        phraseTextField.text = ""
        phraseTextField.placeholder = "Type a new phrase..."
        phraseTextField.resignFirstResponder()
        tableView.reloadData()
    }

}