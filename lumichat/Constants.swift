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
	static func getColor(index: Int) -> CGColor
	{
		return colors[index].CGColor
	}
	
	static func getColorName(index: Int) -> String
	{
		return colorNames[index]
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