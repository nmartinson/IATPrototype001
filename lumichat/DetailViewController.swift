//
//  DetailViewController.swift
//  DatabaseTable
//
//  Created by Nick Martinson on 8/8/14.
//  Copyright (c) 2014 BAapps. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import QuartzCore

class DetailViewController: UIViewController, AVAudioPlayerDelegate
{
	@IBOutlet weak var createButton: UIButton!
	@IBOutlet weak var alertText: UITextField!
	var player : AVAudioPlayer! = nil // will be Optional, must supply initializer
	var cellName: String = ""
	var buttonTitle = ""
	var link = ""
	var buttons: [UIButton] = []
	var buttonCount = 0
	var height = CGFloat(100)
	var width = CGFloat(100)
	var x = CGFloat(10)
	var y = CGFloat(100)
	var buttonStore = NSMutableData()
	var timer = NSTimer()
	var timeInterval: Double = 0.0
	var buttonStyle = 0
	var buttonBorderColor = 0
	var buttonBorderWidth: CGFloat = 0
	var colorNames = [ "Black", "Blue", "Red", "Yellow", "Orange", "Green"]
	var colors = [UIColor.blackColor(), UIColor.blueColor(), UIColor.redColor(), UIColor.yellowColor(), UIColor.orangeColor(), UIColor.greenColor()]
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		y = 100
		var defaults = NSUserDefaults.standardUserDefaults()
		timeInterval = defaults.doubleForKey("scanRate")
		buttonStyle = defaults.integerForKey("buttonStyle")
		buttonBorderColor = defaults.integerForKey("buttonBorderColor")
		buttonBorderWidth = CGFloat (defaults.integerForKey("buttonBorderWidth"))
		
		timer.invalidate()
		timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("scanButtons"), userInfo: nil, repeats: true)
		
		var path = createDBPath()
		let database = FMDatabase(path: path)
		database.open()
		var results = FMResultSet()
		if(database.tableExists("\(link)"))
		{
			results = database.executeQuery("SELECT * FROM \(link)",withArgumentsInArray: nil)
			
			do{
				var num = results.intForColumn("number")
				var title = results.stringForColumn("title")
				var image = results.stringForColumn("image")
				println("\(num) \(title)")
//				var buttonObject = results.dataForColumn("object")
//				var decodedButton = NSKeyedUnarchiver.unarchiveObjectWithData(buttonObject) as UIButton
//				buttons.append(decodedButton)
				
				if( num != 0 && num % 5 == 0)
				{
					y += 150
					x = 10
				}
				if(title != nil)
				{
					configButton(title)
				}
			}while( results.next() )
		}
		database.close()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// Used for button creation through UIAlert
	// Gets called when the user clicks 'OK' for the alert box
	func wordEntered(data: String){
		buttonTitle = data
		if( buttons.count != 0 && buttons.count % 5 == 0)
		{
			y += 150
			x = 10
		}
		
		let path = createDBPath()
		let database = FMDatabase(path: path)
		database.open()
		
//		var encodedObject = NSKeyedArchiver.archivedDataWithRootObject(buttons[buttons.count-1])
		
		/* *********************************************************************************
			When dropping tables and recreating them, the button count can get out of sync
			and cause problems with updating the database.  NEED A FIX
		********************************************************************************** */
		var array = [buttons.count, "\(buttonTitle)", "buttonTest.jpg", 1]
//		var array = [buttons.count, "\(buttonTitle)", encodedObject, 1]

//		database.executeUpdate("DROP TABLE \(link)", withArgumentsInArray: nil)
		database.executeUpdate("CREATE TABLE IF NOT EXISTS \(link)(number INT primary key, title TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
		database.executeUpdate("INSERT INTO \(link)(number, title, image, presses) values(?,?,?,?)", withArgumentsInArray: array)
		database.close()
		configButton(buttonTitle)
	}
	
	
	// Creates a button and sets the proper title
	func configButton(label: String)
	{
		var button = UIButton.buttonWithType(.System) as UIButton
		button.frame = CGRectMake(x, y, width, height)
		button.addTarget(self, action: "playMyFile:", forControlEvents: UIControlEvents.TouchUpInside)
		button.isAccessibilityElement = true
		
		switch buttonStyle
		{
			case 0:
				button.setTitle("\(label)", forState: .Normal)
				button.setTitleColor(UIColor.blackColor(), forState: .Normal)
				let btnImage: UIImage = UIImage(named:"buttonTest.jpg")
				button.setBackgroundImage(btnImage, forState: .Normal)
			case 1:
				button.setTitle("\(label)", forState: .Normal)
				button.setTitleColor(UIColor.blackColor(), forState: .Normal)
			case 2:
				let btnImage: UIImage = UIImage(named:"buttonTest.jpg")
					button.setBackgroundImage(btnImage, forState: .Normal)
			default:
				println("Button style issue")
		}
		
		buttons.append(button)
		x = x+150
		self.view.addSubview(button)
	}
	
	func playMyFile(sender: UIButton!) {
		var title = sender.titleLabel.text!
		var formattedTitle = title.stringByReplacingOccurrencesOfString(" ", withString: "_")
		
		let path = NSBundle.mainBundle().pathForResource("\(formattedTitle)", ofType:"wav")
		let fileURL = NSURL(fileURLWithPath: path)
		player = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
		player.prepareToPlay()
		player.delegate = self
		player.play()
		timer.invalidate()		// stops the timer
		sender.selected = false
		sender.highlighted = false
	}
	
	func createDBPath() -> String
	{
		let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
		let docsPath: String = paths
		let path = docsPath.stringByAppendingPathComponent("UserDatabase.sqlite")
		return path
	}
	
	func scanButtons()
	{
		if( !buttons.isEmpty)
		{
			var next = 0
			var counter = 0
			for item in buttons
			{
				if item.selected == true
				{
					item.selected = false
					item.layer.borderWidth = 0
					item.highlighted = false
					if counter + 1 == buttons.count
					{
						createButton.selected = true
						createButton.layer.borderColor = colors[buttonBorderColor].CGColor
						next = 0
					}
					else
					{
						next = counter + 1
					}
				}
				counter++
			}
			if( !createButton.selected == true)
			{
			buttons[next].selected = true
			buttons[next].highlighted = true
			buttons[next].layer.borderColor = colors[buttonBorderColor].CGColor
			buttons[next].layer.borderWidth = buttonBorderWidth
			}
		}
	}
	
	// Using closures to get data from the modal view used for button creation
	 override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
		if let viewController = segue.destinationViewController as? CreateButtonViewController{
			viewController.availableData = {[weak self]
				(data) in
				if let weakSelf = self{
					weakSelf.wordEntered(data)
				}
			}
		}
	}
	
}
	
	

