/*
 Copyright (c) 2016 Sachin Verma
 
 SVContactBubble.swift
 SVContactBubbleView
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


import UIKit

class SVContactBubble: UIView
{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var actionClosure: ((bubble: SVContactBubble)-> ())?
    
    var isSelected: Bool = false
    
    class func contactBubbleView(title: String, image: UIImage? = nil) -> SVContactBubble?
    {
        let viewArray:Array = NSBundle.mainBundle().loadNibNamed("SVContactBubble", owner: self, options: nil)
        
        guard let contactBubble =  viewArray.first as? SVContactBubble else{
            return nil
        }
    
        let oldTextWidth = contactBubble.titleLabel.bounds.width
        
        contactBubble.titleLabel.text = title
        contactBubble.titleLabel.sizeToFit()
        contactBubble.titleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        let newTextWidth = contactBubble.titleLabel.bounds.width
        
        contactBubble.layer.cornerRadius = 10.0
        contactBubble.layer.borderWidth = 1.0
        contactBubble.layer.borderColor = UIColor.grayColor().CGColor
        contactBubble.clipsToBounds = true
        
        // Resize to fit text
        contactBubble.frame.size = CGSizeMake(contactBubble.frame.size.width + (newTextWidth - oldTextWidth), contactBubble.frame.height)
        contactBubble.actionButton?.frame = CGRectMake(0, 0,contactBubble.frame.size.width , contactBubble.frame.size.height)
        contactBubble.setNeedsLayout()
        contactBubble.frame = contactBubble.frame
        
        return contactBubble
    }
    
    
    @IBAction func bubbleDeleted(sender: AnyObject) {
        if actionClosure != nil {
            actionClosure!(bubble: self)
        }
    
    }
}
