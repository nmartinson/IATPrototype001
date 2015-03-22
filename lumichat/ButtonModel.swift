//
//  ButtonModel.swift
//  lumichat
//
//  Created by Nick Martinson on 3/18/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit


/******************************************************************************************
*   title:  The title of the button that is displayed
*   longDescription:    The longer sentence that can be associated with the button (optional)
*   imagePath:  The file path of where the image is saved
*   linkedPage: The name of the page that the button links to (optional)
******************************************************************************************/
class ButtonModel:NSObject
{
    var title:String
    var longDescription:String
    var imagePath:String
    var linkedPage:String?
    
    
    init(title: String, longDescription: String, imagePath: String)
    {
        self.title = title
        self.imagePath = imagePath
        self.longDescription = longDescription
    }
    
    init(title: String, longDescription: String, imagePath: String, linkedPage: String)
    {
        self.title = title
        self.imagePath = imagePath
        self.longDescription = longDescription
        self.linkedPage = linkedPage
    }
}