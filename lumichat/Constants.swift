//
//  Constants.swift
//  DatabaseTable
//
//  Created by Nick Martinson on 9/16/14.
//  Copyright (c) 2014 BAapps. All rights reserved.
//

import Foundation


enum Constants
{
	
	static var colorNames = [ "Black", "Blue", "Red", "Yellow", "Orange", "Green"]
	static var colors = [UIColor.blackColor(), UIColor.blueColor(), UIColor.redColor(), UIColor.yellowColor(), UIColor.orangeColor(), UIColor.greenColor()]
//	static var cellSize = [CGSizeMake(150, 170), CGSizeMake(180, 200), CGSizeMake(230, 250)]
    static let cellSize = [CGSizeMake(UIScreen.mainScreen().bounds.width/5.2, UIScreen.mainScreen().bounds.height/6.6),
        CGSizeMake(UIScreen.mainScreen().bounds.width/4.2, UIScreen.mainScreen().bounds.height/5.6),
        CGSizeMake(UIScreen.mainScreen().bounds.width/3.2, UIScreen.mainScreen().bounds.height/4.6)]


	static func getColor(index: Int) -> CGColor
	{
		return colors[index].CGColor
	}
	
	static func getColorName(index: Int) -> String
	{
		return colorNames[index]
	}
	
    static func getCellSize(index: Int, numberOfButtons: Int) -> CGSize
	{
//        println("num buttons \(numberOfButtons)")
        if index == 3
        {
            let numButtons = CGFloat(numberOfButtons)/2.0

            let screenWidth = UIScreen.mainScreen().bounds.width
            let screenHeight = UIScreen.mainScreen().bounds.height
            return CGSizeMake(screenWidth/CGFloat(numButtons), screenHeight/CGFloat(numButtons))
        }
		return cellSize[index]
	}
    
    
    static func getTime() -> String
    {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm"
        let time = formatter.stringFromDate(date)
        return time
    }
}