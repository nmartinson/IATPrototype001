//
//  ButtonModel.swift
//  lumichat
//
//  Created by Nick Martinson on 3/18/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

class ButtonModel:NSObject
{
    var imageTitle:String
    var title:String
    var longDescription:String
    var imagePath:String
    var linkedPage:String?
    
    
    init(title: String, imageTitle: String, longDescription: String, imagePath: String)
    {
        self.title = title
        self.imagePath = imagePath
        self.imageTitle = imageTitle
        self.longDescription = longDescription
    }
    
    init(title: String, imageTitle: String, longDescription: String, imagePath: String, linkedPage: String)
    {
        self.title = title
        self.imagePath = imagePath
        self.imageTitle = imageTitle
        self.longDescription = longDescription
        self.linkedPage = linkedPage
    }
}