//
//  ScanController.swift
//  lumichat
//
//  Created by Nick Martinson on 10/31/14.
//  Copyright (c) 2014 BAapps. All rights reserved.
//

import Foundation

public class ScanController
{
    
    public var cellArray: NSMutableArray = []	// stores ButtonCells
    var size:CGSize!
    var timer = NSTimer()
    var timeInterval: Double = 0.0	// used as scan rate - from settings
    var buttonBorderColor = 0	// from settings
    var buttonBorderWidth: CGFloat = 10	// from settings
    var buttonStyle = 0	// from settings
    var scanMode = 0	// from settings
    var buttonSize = 0
    var index = 0
    var elementScanningCounter = 0
    var secondStageOfSelection = false
    var endIndex = 0
    var startIndex = 0
    
    public class var sharedInstance: ScanController{
        struct SharedInstance {
            static let instance = ScanController()
        }
        return SharedInstance.instance
    }
    
    func reloadData(size: CGSize)
    {
        initialization()
        cellArray.removeAllObjects()
        self.size = size
        update()
    }
    
    func initialization()
    {
        timer.invalidate()
        clearAllButtonSelections()
        index = 0
        startIndex = 0
        endIndex = 0
        secondStageOfSelection = false
        elementScanningCounter = 0
    }

    func update()
    {
        var defaults = NSUserDefaults.standardUserDefaults()
        self.timeInterval = defaults.doubleForKey("scanRate")
        self.buttonStyle = defaults.integerForKey("buttonStyle")
        self.buttonBorderColor = defaults.integerForKey("buttonBorderColor")
        self.buttonBorderWidth = CGFloat (defaults.integerForKey("buttonBorderWidth"))
        self.buttonSize = defaults.integerForKey("buttonSize")
        self.scanMode = defaults.integerForKey("scanMode")
        setScanMode()
    }
    
    func addCell(cell: ButtonCell)
    {
        self.cellArray.addObject(cell)
    }
    
    /****************************************************************************************************
    *	Serial Scanning	- Needs work so that the create and back buttons are in the scan
    ************************************************************************************************** */
    @objc func serialScan()
    {
        if( cellArray.count > 0)
        {
            var next = 0
            var counter = 0
            for item in cellArray
            {
                if( (item as ButtonCell).selected == true )
                {
                    (item as ButtonCell).selected = false
                    (item as ButtonCell).layer.borderWidth = 0
                    (item as ButtonCell).highlighted = false
                    if counter + 1 == cellArray.count
                    {
//                        createButton.selected = true
//                        createButton.layer.borderColor = Constants.getColor(buttonBorderColor)
                        next = 0
                    }
                    else
                    {
                        next = counter + 1
                    }
                }
                counter++
                
            }
//            index = next
//            if( createButton.selected == false)
//            {

                index = next  // set index to currently selected button to be used for playing audio

                (cellArray[next] as ButtonCell).selected = true
                (cellArray[next] as ButtonCell).highlighted = true
                (cellArray[next] as ButtonCell).layer.borderColor = Constants.getColor(buttonBorderColor)
                (cellArray[next] as ButtonCell).layer.borderWidth = buttonBorderWidth
//            }
//            else if( createButton.selected == true && next == 0)
//            {
//                createButton.selected = false
//                createButton.layer.borderWidth = 0
//                (cellArray[next] as ButtonCell).selected = true
//                (cellArray[next] as ButtonCell).highlighted = true
//                (cellArray[next] as ButtonCell).layer.borderColor = Constants.getColor(buttonBorderColor)
//                (cellArray[next] as ButtonCell).layer.borderWidth = buttonBorderWidth
//            }
        }
    }
    
    /* *****************************************************************************************************
    *	Row Scanning
    ***************************************************************************************************** */
    @objc func rowScan()
    {
        var cellWidth = Constants.getCellSize(buttonSize).width
        var cellHeight = Constants.getCellSize(buttonSize).height
        var numbtns:Int = Int( (size.width-15)/(cellWidth+15) )
        var numbtnsHeight:Int = Int( (size.height-15)/(cellHeight+15) + 0.5)	// add .5 so that it rounds to the nearest integer, not always down
        
        // Clear the previously selected items
        clearAllButtonSelections()
        
        if( !secondStageOfSelection)
        {
            startIndex = endIndex
            if( endIndex == cellArray.count)
            {
                endIndex = 0
                startIndex = 0
            }
            if(endIndex+numbtns < cellArray.count)
            {
                endIndex += numbtns
            }
            else
            {
                endIndex = cellArray.count
            }
            
            for(var i = startIndex; i < endIndex; i++)
            {
                (cellArray[i] as ButtonCell).selected = true
                (cellArray[i] as ButtonCell).highlighted = true
                (cellArray[i] as ButtonCell).layer.borderWidth = buttonBorderWidth
                (cellArray[i] as ButtonCell).layer.borderColor = Constants.getColor(buttonBorderColor)
            }
        }
        else
        {
            index = startIndex + numbtns * elementScanningCounter
            // if the calculated index is larger than the deck size, set the index equal to the last element in the deck
            if(index < cellArray.count)
            {
                (cellArray[index] as ButtonCell).selected = true
                (cellArray[index] as ButtonCell).highlighted = true
                (cellArray[index] as ButtonCell).layer.borderWidth = buttonBorderWidth
                (cellArray[index] as ButtonCell).layer.borderColor = Constants.getColor(buttonBorderColor)
            }
            elementScanningCounter++
            // If at the last button or at the end of the row, reset the scanning counter to 0
            // Have to also check if its the last button, because for rows that aren't completely full of buttons
            // The test for button width fails because numbtnsWidth holds the number of buttons that can fit
            if(elementScanningCounter == numbtnsHeight)
            {
                elementScanningCounter = 0
            }
        }
    }

    
    /* *********************************************************************************************************
    *	Column Scanning
    ********************************************************************************************************** */
    @objc func columnScan()
    {
        var cellHeight = Constants.getCellSize(buttonSize).height
        var cellWidth = Constants.getCellSize(buttonSize).width
        var numbtnsWidth:Int = Int( (size.width-15)/(cellWidth+15) )
        var numbtnsHeight:Int = Int( (size.height-15)/(cellHeight+15) + 0.5)	// add .5 so that it rounds to the nearest integer, not always down
        
        // Clear the selection properties from all buttons
        clearAllButtonSelections()
        
        // executed if it is the first stage of the scanning process
        if( !secondStageOfSelection )
        {
            if( startIndex == numbtnsWidth)
            {
                startIndex = 0
            }
            
            for(var i = 0; i < numbtnsHeight; i++)
            {
                index = startIndex + i * numbtnsWidth	//calculates the proper array index for selecting buttons in a column
                if( index < cellArray.count)
                {
                    (cellArray[index] as ButtonCell).selected = true
                    (cellArray[index] as ButtonCell).highlighted = true
                    (cellArray[index] as ButtonCell).layer.borderWidth = buttonBorderWidth
                    (cellArray[index] as ButtonCell).layer.borderColor = Constants.getColor(buttonBorderColor)
                }
            }
            
            startIndex += 1
        }
        else	// executed if it is the second stage of the scanning process
        {
            index = startIndex * numbtnsWidth + elementScanningCounter // calculates proper array for scanning buttons in a column
            
            // if the calculated index is larger than the deck size, set the index equal to the last element in the deck
            if(index >= cellArray.count)
            {
                index = cellArray.count - 1
            }
            
            (cellArray[index] as ButtonCell).selected = true
            (cellArray[index] as ButtonCell).highlighted = true
            (cellArray[index] as ButtonCell).layer.borderWidth = buttonBorderWidth
            (cellArray[index] as ButtonCell).layer.borderColor = Constants.getColor(buttonBorderColor)
            
            elementScanningCounter++
            // If at the last button or at the end of the row, reset the scanning counter to 0
            // Have to also check if its the last button, because for rows that aren't completely full of buttons
            // The test for button width fails because numbtnsWidth holds the number of buttons that can fit
            
            var tmp = Double(index + 1)
            var tmp2 = Double(numbtnsWidth)
            var row:Int = Int(ceil(tmp/tmp2))
            
            if(index != 0 && (index == cellArray.count - 1 || index == row * numbtnsWidth - 1) )//index == numbtnsWidth - 1  )
            {
                elementScanningCounter = 0
            }
        }
    }
    
    /********************************************************************************************************
    *   Deselects all the buttons
    ********************************************************************************************************/
    func clearAllButtonSelections()
    {
        // Clear the selection properties from all buttons
        for item in cellArray
        {
            if( (item as ButtonCell).selected == true )
            {
                (item as ButtonCell).selected = false
                (item as ButtonCell).layer.borderWidth = 0
                (item as ButtonCell).highlighted = false
            }
        }
    }
    
    /* ************************************************************************************************
    *	Sets the button size
    *	0 = serial scan
    *	1 = block scan
    *	2 = row column scan
    *	3 = column row scan
    ************************************************************************************************* */
    func setScanMode()
    {
        timer.invalidate()
        switch scanMode
        {
        case 0:
            timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("serialScan"), userInfo: nil, repeats: true)
        case 1:
            timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("blockScan"), userInfo: nil, repeats: true)
        case 2:
            timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("rowScan"), userInfo: nil, repeats: true)
        case 3:
            timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("columnScan"), userInfo: nil, repeats: true)
        default:
            println("Error")
        }
    }
    
    
    /* ***********************************************************************************************************
    *	Gets called when the user taps the screen. If using srial scan, it calls for the button to pressed, which
    *   plays the audio. If a different scan mode, it checks if it was the first tap or second tap. First tap changes
    *   scan mode, second selection, makes the selection.
    *********************************************************************************************************** */
    func selectionMade(playAudio: Bool)
    {
        timer.invalidate()
        if(scanMode == 0) // if serial scan, make selection
        {
            if( playAudio)
            {
                (cellArray[index] as ButtonCell).buttonPressRelease(self)
            }
            (cellArray[index] as ButtonCell).selected = false
            (cellArray[index] as ButtonCell).layer.borderWidth = 0
        }
        else
        {
            if( secondStageOfSelection)
            {
                if( playAudio)
                {
                    (cellArray[index] as ButtonCell).buttonPressRelease(self)
                }
                (cellArray[index] as ButtonCell).selected = false
                (cellArray[index] as ButtonCell).layer.borderWidth = 0
            }
            secondStageOfSelection = !secondStageOfSelection
            elementScanningCounter = 0	// set to 0 so it starts scanning with the left button
            
            switch scanMode
            {
            case 0:
                scanMode = 0
            case 1:
                scanMode = 1
            case 2:
                var cellWidth = Constants.getCellSize(buttonSize).width
                var numbtns:Int = Int( (size.width-15)/(cellWidth+15) )
                startIndex /= numbtns
                scanMode = 3	// change to column scan
            case 3:
                startIndex -= 1
                scanMode = 2	// change to row scan
            default:
                println("Error")
            }
        }
        setScanMode()   // this resets the timer to start scanning again
    }
    
}