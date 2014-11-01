//
//  ScannerDrawer.swift
//  DatabaseTable
//
//  Created by Nick Martinson on 8/21/14.
//  Copyright (c) 2014 BAapps. All rights reserved.
//

import Foundation

class ScannerDrawer: UIView
{
	var rectangle = CGRectMake(0,0,0,0)
	var x:CGFloat = 7
	var y:CGFloat = 70
	var width: CGFloat = 755
	var height: CGFloat = 135
	var cellSize: CGSize = CGSizeMake(1, 1)
	var dx:CGFloat = 1
	var dy:CGFloat = 1
	
	func setup(buttonSize: Int, index: Int)
	{
		self.cellSize.width = Constants.getCellSize(index).width
		self.cellSize.height = Constants.getCellSize(index).height
		
	}
	
	/* *******************************************************************
	*	size (CGSize): collection view dimensions
	*	scanMode (Int): the button scanning method
	******************************************************************** */
	func move(scanMode: Int, size: CGSize)
	{
		dx = cellSize.width/size.width
		var numbtns:Int = Int( (size.width-15)/(cellSize.width+15) )
		var btnspace = (cellSize.width/size.width)*size.width
		var whiteSpace = ((size.width - btnspace)/CGFloat(numbtns))
		dx = whiteSpace/CGFloat(numbtns - 1)
		println("WS \(whiteSpace) btns \(numbtns) dx \(dx)")
//		println(numbtns)
//		println(dx)
		
		switch scanMode
		{
			// Serial Scanning
			case 0:
				rectangle = CGRectMake(x, y, width, height)
				y = y + height
			
			// Block Scanning
			case 1:
			rectangle = CGRectMake(x, y, width, height)
				y = y + height
			
			// Row Scanning
			case 2:
				if ( y > size.height)
				{
					y = 70
				}
				rectangle = CGRectMake(x, y, size.width, cellSize.height)
				y = y + cellSize.height+5
			
			// Column Scanning
			case 3:
				if ( x > size.width - 30)
				{
					x = 10
				}
				rectangle = CGRectMake(x, y, cellSize.width + 10, size.height)
				x = x + cellSize.width + 7 + dx
			
			default:
				println("error")
		}
	}
	
	
	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
		var context = UIGraphicsGetCurrentContext()
		
		CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 0.5)
		CGContextFillRect(context, rectangle)
		
	}
}