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
    
    public class var sharedInstance: ScanController{
        struct SharedInstance {
            static let instance = ScanController()
        }
        return SharedInstance.instance
    }
    
    func reloadData(size: CGSize, numButtons: Int)
    {
        initialization()
        cellArray.removeAllObjects()
        numberOfButtons = numButtons
        update()
    }
    
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

    override func update()
    {
        super.update()
        buttonStyle = defaults.integerForKey("buttonStyle")
        buttonSize = defaults.integerForKey("buttonSize")
        scanMode = defaults.integerForKey("scanMode")
        setScanMode()
    }

    func setRowsAndCols(rows: Int, cols: Int)
    {
        self.rows = rows
        self.cols = cols
    }
    
    func addCell(cell: ButtonCell)
    {
        self.cellArray.addObject(cell)
    }
    
    func stopScan()
    {
        clearAllButtonSelections()
        timer.invalidate()
    }
    
    
    /****************************************************************************************************
    *   Scans over the navBar buttons
    ************************************************************************************************** */
    func navBarScan()
    {
        if !secondStageOfSelection
        {
            for item in navBarButtons
            {
                (item as UIButton).layer.borderWidth = 5
            }
        }
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
                        next = 0
                    }
                    else
                    {
                        next = counter + 1
                    }
                }
                counter++
                
            }

                index = next  // set index to currently selected button to be used for playing audio

                (cellArray[next] as ButtonCell).selected = true
                (cellArray[next] as ButtonCell).highlighted = true
                (cellArray[next] as ButtonCell).layer.borderColor = Constants.getColor(buttonBorderColor)
                (cellArray[next] as ButtonCell).layer.borderWidth = buttonBorderWidth
                (cellArray[next] as ButtonCell).layer.cornerRadius = 5
        }
    }
    
    /* *****************************************************************************************************
    *	Row Scanning
    ***************************************************************************************************** */
    @objc func rowScan()
    {
        clearAllButtonSelections()
        if !secondStageOfSelection
        {
            if firstIndexInRow >= cellArray.count//rows - 1//currentRow > rows + cols
            {
                firstIndexInRow = 0
            }

            for(var i = 0; i < cols; i++)
            {
                index = i + firstIndexInRow
                if(index < cellArray.count)
                {
                    (cellArray[index] as ButtonCell).selected = true
                    (cellArray[index] as ButtonCell).highlighted = true
                    (cellArray[index] as ButtonCell).layer.borderWidth = buttonBorderWidth
                    (cellArray[index] as ButtonCell).layer.borderColor = Constants.getColor(buttonBorderColor)
                    (cellArray[index] as ButtonCell).layer.cornerRadius = 5
                }
            }
            firstIndexInRow += cols //+= cols
        }
        else
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
                (cellArray[index] as ButtonCell).selected = true
                (cellArray[index] as ButtonCell).highlighted = true
                (cellArray[index] as ButtonCell).layer.borderWidth = buttonBorderWidth
                (cellArray[index] as ButtonCell).layer.borderColor = Constants.getColor(buttonBorderColor)
                (cellArray[index] as ButtonCell).layer.cornerRadius = 5
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
        
        if !secondStageOfSelection
        {
            if firstIndexInCol == cols
            {
                firstIndexInCol = 0
            }
            
            for(var i = 0; i < rows; i++)
            {
                index = firstIndexInCol + i * cols
                if(index < cellArray.count)
                {
                    (cellArray[index] as ButtonCell).selected = true
                    (cellArray[index] as ButtonCell).highlighted = true
                    (cellArray[index] as ButtonCell).layer.borderWidth = buttonBorderWidth
                    (cellArray[index] as ButtonCell).layer.borderColor = Constants.getColor(buttonBorderColor)
                    (cellArray[index] as ButtonCell).layer.cornerRadius = 5
                }
            }
            firstIndexInCol += 1 //+= cols
        }
        else
        {
            // if the last element was just selected, restart at beginning of row
            if index >= cellArray.count - 1 || index == firstIndexInRow + cols - 1
            {
                elementScanningCounter = 0
            }
            
            index = firstIndexInRow + elementScanningCounter
            if(index < cellArray.count)
            {
                (cellArray[index] as ButtonCell).selected = true
                (cellArray[index] as ButtonCell).highlighted = true
                (cellArray[index] as ButtonCell).layer.borderWidth = buttonBorderWidth
                (cellArray[index] as ButtonCell).layer.borderColor = Constants.getColor(buttonBorderColor)
                (cellArray[index] as ButtonCell).layer.cornerRadius = 5
            }
            elementScanningCounter++
        }
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
        default:
            println("Error")
        }
    }
    
    
    /* ***********************************************************************************************************
    *	Gets called when the user taps the screen. If using srial scan, it calls for the button to pressed, which
    *   plays the audio. If a different scan mode, it checks if it was the first tap or second tap. First tap changes
    *   scan mode, second selection, makes the selection.
    *********************************************************************************************************** */
    override func selectionMade(playAudio: Bool)
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
                    firstIndexInRow = firstIndexInRow - cols
                    scanMode = 3	// change to column scan
                case 3:
                    firstIndexInCol = firstIndexInCol - 1
                    scanMode = 2	// change to row scan
                default:
                    println("Error")
            }
        }
        setScanMode()   // this resets the timer to start scanning again
    }
}