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
	static var cellSize = [CGSizeMake(150, 170), CGSizeMake(180, 200), CGSizeMake(230, 250)]

	static func getColor(index: Int) -> CGColor
	{
		return colors[index].CGColor
	}
	
	static func getColorName(index: Int) -> String
	{
		return colorNames[index]
	}
	
	static func getCellSize(index: Int) -> CGSize
	{
		return cellSize[index]
	}
}