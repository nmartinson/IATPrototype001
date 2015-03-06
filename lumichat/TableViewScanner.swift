//
//  TableViewScanner.swift
//  lumichat
//
//  Created by Nick Martinson on 2/11/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation


class TableViewScanner: Scanner
{
    public class var sharedInstance: TableViewScanner{
        struct SharedInstance {
            static let instance = TableViewScanner()
        }
        return SharedInstance.instance
    }
    
    var currentCell = 0
    var previousCell = 0
    var dataSource: NSMutableArray = []
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func initialization(data: NSMutableArray)
    {
        dataSource = data
        update()
        setScanMode()
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func setScanMode()
    {
        timer.invalidate()
//        switch scanMode
//        {
//        case 0:
            timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("serialScan"), userInfo: nil, repeats: true)
//        case 1:
//            timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("blockScan"), userInfo: nil, repeats: true)
//        default:
//            println("Error")
//        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func addCell(cell: UITableViewCell)
    {
        dataSource.addObject(cell)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @objc func serialScan()
    {
        clearAllCells()
        
        if currentCell == 0
        {
            (dataSource[currentCell] as UITextField).layer.borderColor = UIColor.blackColor().CGColor
            (dataSource[currentCell] as UITextField).layer.borderWidth = 2
        }
        else
        {
            (dataSource[currentCell] as UITableViewCell).highlighted = true
            (dataSource[currentCell] as UITableViewCell).selected = true
        }
        
        previousCell = currentCell
        
        if currentCell < dataSource.count - 1
        {
            currentCell++
        }
        else
        {
            currentCell = 0
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func clearAllCells()
    {
        (dataSource[0] as UITextField).layer.borderColor = UIColor.blackColor().CGColor
        (dataSource[0] as UITextField).layer.borderWidth = 0
        
        for(var i = 1; i < dataSource.count; i++)
        {
            (dataSource[i] as UITableViewCell).highlighted = false
            (dataSource[i] as UITableViewCell).selected = false

        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func removeAllItemsFromDataSource()
    {
        let range = NSRange(location: 1, length: dataSource.count - 1)
        dataSource.removeObjectsInRange(range)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func selectionMade(playAudio: Bool)
    {
        timer.invalidate()
        var selectedObject:AnyObject?
        println("cell \(previousCell)")
        if previousCell == 0
        {
            selectedObject = dataSource[0] as UITextField
            selectedObject?.becomeFirstResponder()
            
        }
        else
        {
            selectedObject = dataSource[previousCell] as UITableViewCell
            println((selectedObject as UITableViewCell).textLabel!.text)
        }
        
        
        
        secondStageOfSelection = !secondStageOfSelection
        
        setScanMode()   // this resets the timer to start scanning again
    }
    
}