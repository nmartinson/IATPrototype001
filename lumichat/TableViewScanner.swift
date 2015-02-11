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
    override internal class var sharedInstance: TableViewScanner{
        struct SharedInstance {
            static let instance = TableViewScanner()
        }
        return SharedInstance.instance
    }
    
    var dataSource: NSMutableArray = []
    
    func initialize(data: NSMutableArray)
    {
        dataSource = data
        
    }
    
}