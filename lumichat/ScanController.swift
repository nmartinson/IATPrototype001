//
//  ScanController.swift
//  lumichat
//
//  Created by Nick Martinson on 10/31/14.
//  Copyright (c) 2014 BAapps. All rights reserved.
//

import Foundation

class ScanController: Scanner
{
    var cellArray: NSMutableArray = []	// stores ButtonCells
    var index = 0
    var elementScanningCounter = 0
    var numberOfButtons = 0
    var timer = NSTimer()
    var rows = 0
    var cols = 0
    var firstIndexInRow = 0
    var firstIndexInCol = 0
    var navBarScanning = false
    var currentNavBarIndex = 0
    
    public class var sharedInstance: ScanController{
        struct SharedInstance {
            static let instance = ScanController()
        }
        return SharedInstance.instance
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func reloadData(size: CGSize, numButtons: Int)
    {
        initialization()
        cellArray.removeAllObjects()
        numberOfButtons = numButtons
        update()
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func initialization()
    {
        timer.invalidate()
        clearAllButtonSelections()
        index = 0
        firstIndexInCol = 0
        firstIndexInRow = 0
        secondStageOfSelection = false
        elementScanningCounter = 0
    }

    /******************************************************************************************
    *
    ******************************************************************************************/
    override func update()
    {
        super.update()
        buttonStyle = defaults.integerForKey("buttonStyle")
        buttonSize = defaults.integerForKey("buttonSize")
        scanMode = defaults.integerForKey("scanMode")
        setScanMode()
    }

    /******************************************************************************************
    *
    ******************************************************************************************/
    func setRowsAndCols(rows: Int, cols: Int)
    {
        self.rows = rows
        self.cols = cols
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func addCell(cell: ButtonCell)
    {
        self.cellArray.addObject(cell)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func stopScan()
    {
        clearAllButtonSelections()
        timer.invalidate()
    }
    
    
    /****************************************************************************************************
    *   Scans over the navBar buttons
    ************************************************************************************************** */
    @objc func navBarScan()
    {
        clearAllButtonSelections()
        if !secondStageOfSelection
        {
            for item in navBarButtons
            {
                (item as UIButton).layer.borderWidth = 5
            }
        }
        else
        {
            if navBarButtons.count > 0
            {
                if index > navBarButtons.count - 1
                {
                    index = 0
                }
                
                navBarButtons[index].layer.borderWidth = 5
                index++
            }
        }
    }
    
    /****************************************************************************************************
    *	Serial Scanning	- Needs work so that the create and back buttons are in the scan
    ************************************************************************************************** */
    @objc func serialScan()
    {
        clearAllButtonSelections()
        navBarScanning = false
        
        if cellArray.count > 0
        {
            if index >= cellArray.count
            {
                index = 0
                if navBarButtons.count > 0
                {
                    navBarScan()
                    navBarScanning = true
                }
            }
            if !navBarScanning
            {
                highlightButton(index)
                index++
            }
        }
    }
    
    /* *****************************************************************************************************
    *	Row Scanning
    ***************************************************************************************************** */
    @objc func rowScan()
    {
        navBarScanning = false

        clearAllButtonSelections()
        if !secondStageOfSelection
        {
            if firstIndexInRow >= cellArray.count
            {
                firstIndexInRow = 0
                // only if there is a back button on the bar should we call navScanning
                if navBarButtons.count > 0
                {
                    navBarScan()
                    navBarScanning = true
                }
            }

            if !navBarScanning
            {
                for(var i = 0; i < cols; i++)
                {
                    index = i + firstIndexInRow
                    if(index < cellArray.count)
                    {
                        highlightButton(index)
                    }
                }
                firstIndexInRow += cols //+= cols
            }
        }
        else // scan across row
        {
            // if the last element was just selected, restart at beginning of row
            if index >= cellArray.count - 1 || index == firstIndexInRow + cols - 1
            {
                elementScanningCounter = 0
            }
            
            index = firstIndexInRow + elementScanningCounter
            
            if(index < cellArray.count && index >= 0)
            {
                highlightButton(index)
            }
            elementScanningCounter++
        }
    }

    
    /* *********************************************************************************************************
    *	Column Scanning
    ********************************************************************************************************** */
    @objc func columnScan()
    {
        // Clear the selection properties from all buttons
        clearAllButtonSelections()
        navBarScanning = false
        
        if !secondStageOfSelection
        {
            if firstIndexInCol == cols
            {
                firstIndexInCol = 0
                if navBarButtons.count > 0
                {
                    navBarScan()
                    navBarScanning = true
                }
            }
            
            if !navBarScanning
            {
                for(var i = 0; i < rows; i++)
                {
                    index = firstIndexInCol + i * cols
                    if(index < cellArray.count)
                    {
                        highlightButton(index)
                    }
                }
                firstIndexInCol += 1 //+= cols
            }
        }
        else // scan down column
        {
            // calculate if the column is full
            // if #btns/col# < #totalrows then the column is not full
            let btnsInCol = Float(cellArray.count) / Float(firstIndexInCol + 1)
            
            if elementScanningCounter == rows || (elementScanningCounter == rows - 1 && Int(btnsInCol) < rows)
            {
                elementScanningCounter = 0
            }
            
            index = firstIndexInCol + cols * elementScanningCounter
            if(index < cellArray.count)
            {
                highlightButton(index)
            }
            
            elementScanningCounter++
        }

    }
    
    /********************************************************************************************************
    *   Draws border order the specified button
    *   index: The button position in the cellArray
    ********************************************************************************************************/
    func highlightButton(index: Int)
    {
        (cellArray[index] as ButtonCell).selected = true
        (cellArray[index] as ButtonCell).highlighted = true
        (cellArray[index] as ButtonCell).layer.borderWidth = buttonBorderWidth
        (cellArray[index] as ButtonCell).layer.borderColor = Constants.getColor(buttonBorderColor)
        (cellArray[index] as ButtonCell).layer.cornerRadius = 5
    }
    
    /********************************************************************************************************
    *   Deselects all the buttons
    ********************************************************************************************************/
    func clearAllButtonSelections()
    {
        // clear navbar buttons from being highlighted
        for item in navBarButtons
        {
            (item as UIButton).layer.borderWidth = 0
        }
        
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
    override func setScanMode()
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
        case 4:
            timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("navBarScan"), userInfo: nil, repeats: true)
        default:
            println("Error")
        }
    }
    
    
    /* ***********************************************************************************************************
    *	Gets called when the user taps the screen. If using srial scan, it calls for the button to pressed, which
    *   plays the audio. If a different scan mode, it checks if it was the first tap or second tap. First tap changes
    *   scan mode, second selection, makes the selection.
    *   Output: string that specifies which page to link to next. If string == "", don't link, play the sound
    *********************************************************************************************************** */
    override func selectionMade(playAudio: Bool) -> String
    {
        println("Selection made")
        var returnString = ""
        timer.invalidate()
        
        // Just make sure the index isn't out of bounds. There is an issue where it is too large when a double selection
        // is made quickly in the last row if it isnt full
        if index >= cellArray.count
        {
            index = cellArray.count - 1
        }
        
        // if scanning nav bar, immediately make the selection
        if(navBarScanning)
        {
            navBarButtons[0].sendActionsForControlEvents(.TouchUpInside)
            setScanMode()
            secondStageOfSelection = !secondStageOfSelection
        }
        else if(scanMode == 0) // if serial scan, make selection
        {
            if( (cellArray[index] as ButtonCell).buttonObject!.linkedPage! == "") //no link, play sound
            {
                (cellArray[index] as ButtonCell).buttonPressCalledViaCode(self)
            }
            else
            {
                returnString = (cellArray[index] as ButtonCell).buttonObject!.linkedPage!
            }
            (cellArray[index] as ButtonCell).selected = false
            (cellArray[index] as ButtonCell).layer.borderWidth = 0
            setScanMode()   // this resets the timer to start scanning again
        }
        else
        {
            if( secondStageOfSelection)
            {
                if( (cellArray[index] as ButtonCell).buttonObject!.linkedPage! == "") //no link, play sound
                {
                    (cellArray[index] as ButtonCell).buttonPressCalledViaCode(self)
                }
                else
                {
                    returnString = (cellArray[index] as ButtonCell).buttonObject!.linkedPage!
                }
                (cellArray[index] as ButtonCell).selected = false
                (cellArray[index] as ButtonCell).layer.borderWidth = 0
            }
            secondStageOfSelection = !secondStageOfSelection
            elementScanningCounter = 0	// set to 0 so it starts scanning with the left button
            
            if secondStageOfSelection
            {
                switch scanMode
                {
                    case 0:
                        scanMode = 0
                    case 1:
                        scanMode = 1
                    case 2:
                        firstIndexInRow = firstIndexInRow - cols
                    case 3:
                        firstIndexInCol = firstIndexInCol - 1
                    default:
                        println("Error")
                }
            }
            else
            {
                firstIndexInRow = 0
                firstIndexInCol = 0
            }
            setScanMode()   // this resets the timer to start scanning again
        }
        
        return returnString
    }
}