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


class ButtonCell: UICollectionViewCell, AVAudioPlayerDelegate
{
	@IBOutlet weak var buttonImageView: UIImageView!	// displays the button image
	@IBOutlet weak var button: UIButton!	// associates with the button press actions
	@IBOutlet weak var buttonLabel : UILabel!	// displays the button title
//	var player : AVAudioPlayer! = nil // used for speaking the audio files
    var sentenceString:String!
	var imageString = ""
	var voice = AVSpeechSynthesizer()
	
	/* ************************************************************************************************
	*	Initializes important data about the cell. Sets the image and label.
    *   .Highlighted = description
    *   .Selected = image path
    *   .Normal = button title
	************************************************************************************************ */
	func setup(btn: UIButton) {
		
		self.button = UIButton.buttonWithType(.System) as UIButton
		imageString = btn.titleForState(.Selected)!
        sentenceString = btn.titleForState(.Highlighted)
        
        var image:UIImage? = loadImage(btn.titleForState(.Normal)!)
		
		if( image != nil)
		{
			self.buttonImageView.image = image
		}
		self.buttonLabel.text = btn.titleForState(.Normal)
	}

	/* ************************************************************************************************
	*	Gets called when the button is pressed down. Makes the image slightly transparent
	************************************************************************************************ */
	@IBAction func buttonPressDown(sender: AnyObject) {
		self.buttonImageView.alpha = 0.2
	}
	
    
	/* ************************************************************************************************
	*	Gets called when the button is release.  Makes image opaque and calls the function to play the 
	*	audio clip.
	************************************************************************************************ */
	@IBAction func buttonPressRelease(sender: AnyObject) {
		self.buttonImageView.alpha = 1
        
		playMyFile(buttonLabel.text!)
		
	}
	
	/* ************************************************************************************************
	*	Gets called when the press is cancel: when the press turns out to be for dragging the button or
	*	if they drag their finger off the button and release. Restores button to opaque.
	************************************************************************************************ */
	@IBAction func buttonPressCanceled(sender: AnyObject) {
		self.buttonImageView.alpha = 1
	}
	
	/* ************************************************************************************************
	*	Plays the audio file that is attached with each button.
	*	Current the audio is attached to the button name and thats how it finds the file, eventually
	*	it will be TTS or a user recorded file that will have a spefic name.
	************************************************************************************************ */
	func playMyFile(title: String)
	{
        var utterance:AVSpeechUtterance!
        if( sentenceString != "")
        {
            utterance = AVSpeechUtterance(string: sentenceString)
        }
        else
        {
            utterance = AVSpeechUtterance(string: buttonLabel.text)
        }
        
		utterance.rate = AVSpeechUtteranceMinimumSpeechRate
		voice.speakUtterance(utterance)
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
	
	
	func loadImage(title: String!) -> UIImage
	{
		if !( title == "Im Hungry" || title == "Im Thirsty" || title == "Im Tired" || title == "Please Help Me" || title == "Hello" || title == "Goodbye" )
		{
            var formattedTitle = title.stringByReplacingOccurrencesOfString(" ", withString: "_")
            formattedTitle = formattedTitle + ".jpg"
			let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
			let path = documentDirectory.stringByAppendingPathComponent("\(formattedTitle)")
			var image = UIImage(named:path)
			return image!
		}
		else
		{
			return UIImage(named: "buttonTest.jpg")!
		}
	}
	
}