//  ViewController.swift
//  DatabaseTable
//
//  Created by Nick Martinson on 8/8/14.
//  Copyright (c) 2014 BAapps. All rights reserved.
//
//	This is the view controller for the table that is initially presented when the app launches.
//	It is responsible for getting 'category' names from the DB and displaying them in the table
//	which then become links to buttons in that category.

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!
	var cellName: [String] = []
	
	/* *******************************************************************************************************************
	*	Gets called when the view finishes loading. Opens the DB and pulls in all the 'categories' that are stored in the
	*	DB. It stores these categories in the cellName array which are then displayed in table rows.
	******************************************************************************************************************* */
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
		let docsPath: String = paths
		let path = docsPath.stringByAppendingPathComponent("UserDatabase.sqlite")
		let database = FMDatabase(path: path)
		database.open()
		
		var results = FMResultSet()	// creates a resultSet object that will used to iterate through the items return from DB
		// Check if DB table exists before trying to get data from it
		if(database.tableExists("categories"))
		{
			results = database.executeQuery("SELECT * FROM categories",withArgumentsInArray: nil)
			while( results.next() )
			{
				cellName.append( results.stringForColumn("cell") )	// store categorie name in array
			}
		}
		database.close()
	}
	
	/* *******************************************************************************************************************
	*	Gets called automatically when a row in the table gets selected.  It passes the name of the row to the view 
	*	controller that is about to be presented (LXCollectionViewController1), which is used as the name of the DB table
	*	that stores the buttons associated with that row name.
	******************************************************************************************************************* */
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
	{
		if segue.identifier == "showDetail"
		{
			let indexPath = self.tableView.indexPathForSelectedRow()
			let detailsViewController = segue.destinationViewController as LXCollectionViewController1
			var title = self.tableView.cellForRowAtIndexPath(indexPath!)?.textLabel.text
			detailsViewController.navBar = title!
//			detailsViewController.navBar = self.tableView.cellForRowAtIndexPath(indexPath).textLabel.text
			detailsViewController.link = title!.lowercaseString
		}
	}
	
	/* *******************************************************************************************************************
	*	Gets called automatically
	******************************************************************************************************************* */
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/* *******************************************************************************************************************
	*	Gets called automatically
	******************************************************************************************************************* */
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.cellName.count;
	}
	

	
	/* *******************************************************************************************************************
	*	Gets called automatically when a new table row comes into view and displays puts a title into the row.
	*	Table cells are being reused because its more effecient.
	******************************************************************************************************************* */
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
		cell.textLabel.text = self.cellName[indexPath.row]
		
		return cell
	}
	
	/* *******************************************************************************************************************
	*	Gets called automatically when a row is selected in the table.
	*	When the row is selected it calls a segue that was created in the storboard to show the buttons.
	******************************************************************************************************************* */
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		self.performSegueWithIdentifier("showDetail", sender: self)
	}
}

