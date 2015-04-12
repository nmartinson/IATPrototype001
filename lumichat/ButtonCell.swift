//  ButtonCell.swift
//  DraggableCollection
//
//  Created by Nick Martinson on 8/13/14.
//  Copyright (c) 2014 IAT. All rights reserved.
//
//	This class is responsible for the presentation and actions associated with the cells in the 
//	collection view. Each cell stores its image, button, and label. 

import Foundation
import UIKit
import AVFoundation

protocol ButtonCellControllerDelegate
{
    func editButtonWasPressed(buttonTitle: String, didSucceed: Bool)
    func manuallyPressedButton(performSegue: Bool, toPage: String)
}

class ButtonCell: UICollectionViewCell, AVAudioPlayerDelegate
{
	@IBOutlet weak var buttonImageView: UIImageView!	// displays the button image
    @IBOutlet weak var pageLinkImageView: UIImageView!
	@IBOutlet weak var button: UIButton!	// associates with the button press actions
	@IBOutlet weak var buttonLabel : UILabel!	// displays the button title
//	var player : AVAudioPlayer! = nil // used for speaking the audio files
	var voice = AVSpeechSynthesizer()
    var delegate:ButtonCellControllerDelegate?
    var buttonObject:ButtonModel?
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func startShakingButtons() -> CAAnimation
    {
        var transform = CATransform3DMakeRotation(0.08, 0, 0, 1)
        var animation = CABasicAnimation(keyPath: "transform")
        animation.toValue = NSValue(CATransform3D: transform)
        animation.autoreverses = true
        animation.duration = 0.1
        animation.repeatCount = HUGE
        return animation
    }
    
    
    /* ************************************************************************************************
    *	Initializes important data about the cell. Sets the image and label.
    ************************************************************************************************ */
    func setup(button: ButtonModel)
    {
        self.buttonObject = button
        self.button = UIButton.buttonWithType(.System) as! UIButton
        var title = button.title
        
        var image:UIImage? = loadImage(buttonObject!.imagePath)
        
        if( image != nil)
        {
            self.buttonImageView.image = image
        }
        
        self.buttonLabel.text = button.title
    }


	/* ************************************************************************************************
	*	Gets called when the button is pressed down. Makes the image slightly transparent
	************************************************************************************************ */
	@IBAction func buttonPressDown(sender: AnyObject)
    {
		self.buttonImageView.alpha = 0.2
	}
	
	/* ************************************************************************************************
	*	Gets called when the button is released.  Makes image opaque and calls the function to play the
	*	audio clip.
	************************************************************************************************ */
	@IBAction func buttonPressRelease(sender: AnyObject)
    {
        println("Button pressed")
        self.buttonImageView.alpha = 1
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.editMode)
        {
            delegate?.editButtonWasPressed(buttonLabel.text!, didSucceed: true)
        }
        else if buttonObject!.linkedPage! == ""
        {
            playMyFile()
        }
        else
        {
            playMyFile()
            // tell the collectionview class that the button was pressed physically
            delegate?.manuallyPressedButton(true, toPage: buttonObject!.linkedPage!)
        }

	}
    
    
    @IBAction func buttonPressCalledViaCode(sender: AnyObject)
    {
        self.buttonImageView.alpha = 1
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(appDelegate.editMode)
        {
            delegate?.editButtonWasPressed(buttonLabel.text!, didSucceed: true)
        }
        else
        {
            playMyFile()
        }
    }
    
    
	
	/* ************************************************************************************************
	*	Gets called when the press is cancel: when the press turns out to be for dragging the button or
	*	if they drag their finger off the button and release. Restores button to opaque.
	************************************************************************************************ */
	@IBAction func buttonPressCanceled(sender: AnyObject)
    {
		self.buttonImageView.alpha = 1
	}
	
	/* ************************************************************************************************
	*	Plays the audio file that is attached with each button.
	*	Current the audio is attached to the button name and thats how it finds the file, eventually
	*	it will be TTS or a user recorded file that will have a spefic name.
	************************************************************************************************ */
	func playMyFile()
	{
        var utterance:AVSpeechUtterance!
        if( buttonObject!.longDescription != "")
        {
            Util().speak(buttonObject!.longDescription)
//            utterance = AVSpeechUtterance(string: buttonObject!.longDescription)
        }
        else
        {
            Util().speak(buttonLabel.text!)
//            utterance = AVSpeechUtterance(string: buttonLabel.text)
        }
        
//		utterance.rate = AVSpeechUtteranceMinimumSpeechRate
//		voice.speakUtterance(utterance)
//		var formattedTitle = title.stringByReplacingOccurrencesOfString(" ", withString: "_")
//		let path = NSBundle.mainBundle().pathForResource("\(formattedTitle)", ofType:"wav")
//		let fileURL = NSURL(fileURLWithPath: path!)
//		player = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
//		player.prepareToPlay()
//		player.delegate = self
//		player.play()
		self.selected = false
		self.highlighted = false
	}
	
	
    /* ************************************************************************************************
    *	Loads the specified image that is in the database for that button
    ************************************************************************************************ */
	func loadImage(title: String!) -> UIImage
	{
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let imagePath = documentDirectory.stringByAppendingPathComponent(title)
        var image = UIImage(contentsOfFile: imagePath)

        return image!
	}
	
}