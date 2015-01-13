////
////  ModelManager.swift
////  lumichat
////
////  Created by Nick Martinson on 1/12/15.
////  Copyright (c) 2015 Nick Martinson. All rights reserved.
////
//
//import Foundation
//
//
//let sharedInstance = ModelManager()
//
//class ModelManager: NSObject
//{
//    var currentDB: FMDatabase? = nil
//    var importedDB: FMDatabase? = nil
//    
//    class var currentDBinstance: ModelManager
//    {
//        sharedInstance.currentDB = FMDatabase(path: Util.getPath("UserDatabase.sqlite"))
//        
//        return sharedInstance
//    }
//    
//    class var importedDBinstance: ModelManager
//    {
//        sharedInstance.importedDB = FMDatabase(path: Util.getPath("unzippedData/UserDatabase.sqlite"))
//        return sharedInstance
//    }
//    
//    func getAllFrom(table: String, database: String)
//    {
//        switch(database)
//        {
//            case "current":
//                sharedInstance.currentDB?.open()
//                
//                sharedInstance.currentDB?.close()
//            case "imported":
//                sharedInstance.importedDB?.open()
//            
//                sharedInstance.importedDB?.close()
//            default:
//                break
//        }
//    }
//
//}