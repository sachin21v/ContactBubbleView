/*
 Copyright (c) 2016 Sachin Verma
 
 SVContactBubbleView.swift
 SVContactBubbleView
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
let  deleteKey = ""
let  doneKey = "\n"


public protocol SVContactBubbleDataSource
{

    func insetsForContactBubbleView(contactBubbleView: SVContactBubbleView) -> UIEdgeInsets?
    func placeholderTextForContactBubbleView(contactBubbleView: SVContactBubbleView) -> String?
    func numberOfContactBubbleForContactBubbleView(contactBubbleView: SVContactBubbleView) -> Int
    func contactBubbleView(contactBubbleView: SVContactBubbleView, viewForContactBubbleAtIndex index: Int) -> UIView?
}


public protocol SVContactBubbleDelegate
{
    func contactBubbleView(contactBubbleView: SVContactBubbleView, didDeleteBubbleWithTitle title: String)
    func contactBubbleView(contactBubbleView: SVContactBubbleView, didFinishBubbleWithText text: String)
    func contactBubbleView(contactBubbleView: SVContactBubbleView, didChangeText text: String)
    func contactBubbleView(contactBubbleView: SVContactBubbleView, contentSizeChanged size: CGSize)
}

// MARK: -UITextFieldDelegate

extension SVContactBubbleView: UITextViewDelegate
{
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if text == doneKey {
            
            self.delegate?.contactBubbleView(self, didFinishBubbleWithText:textfield.text!)
            return false
        }
        
        if text == deleteKey && textView.text == deleteKey {
            
            if let bubble = self.selectedBubble {
                
                bubble.removeFromSuperview()
                self.contactBubbbles.removeAtIndex(self.contactBubbbles.indexOf(bubble)!)
                self.delegate?.contactBubbleView(self, didDeleteBubbleWithTitle: bubble.titleLabel.text!)
                self.selectedBubble = nil
            }
            else
            {
                self.selectedBubble = self.contactBubbbles.last
            }
            
            return false
            
        }
        else if text == deleteKey {
            
            let string: String = textfield.text!
            let truncatedString = string.substringToIndex(string.endIndex.predecessor())
            self.updatePlaceholderText(truncatedString)
            self.delegate?.contactBubbleView(self, didChangeText: truncatedString)
            return true
        }
        
        var string: String = textfield.text!
        string.appendContentsOf(text)
        self.updatePlaceholderText(string)
        self.delegate?.contactBubbleView(self, didChangeText: string)
        return true
    }
}



public class SVContactBubbleView: UIView
{
    
    @IBInspectable public var dataSource: SVContactBubbleDataSource?
    @IBInspectable public var delegate: SVContactBubbleDelegate?
    
    private var scrollView: UIScrollView = UIScrollView()
    private var textfield: UITextView = UITextView()
    private var placeholderLabel: UILabel = UILabel()
    private var contactBubbbles: [SVContactBubble] = []
    private var contactBubbleInsets: UIEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5) // Default
    private var lastText = ""
    
    // MARK: Constants
    var totalBubbles: Int = 0
    var contactBubbleHeight: CGFloat = 30.0
    var textFieldMinimumWidth: CGFloat = 80.0
    var textFieldHeight: CGFloat = 30.0
    
    private var selectedBubble: SVContactBubble? {
        didSet{
            if let bubble = self.selectedBubble {
                bubble.backgroundColor = UIColor.lightGrayColor()
            }
        }
    }
    
    @IBInspectable var contactBubbleViewBorderColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            self.layer.borderColor = self.contactBubbleViewBorderColor.CGColor
        }
    }
    
    

    override public func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.scrollView.backgroundColor = UIColor.clearColor()
        self.scrollView.autoresizesSubviews = false
        self.addSubview(self.scrollView)
        
        self.placeholderLabel.backgroundColor = UIColor.clearColor()
        self.placeholderLabel.textColor = UIColor.lightGrayColor()
        
        self.textfield.backgroundColor = UIColor.clearColor()
        self.textfield.textColor = UIColor.blackColor()
        self.textfield.font = UIFont.systemFontOfSize(16)
        self.textfield.delegate = self
        self.textfield.scrollEnabled = false
        self.textfield.returnKeyType = UIReturnKeyType.Done
        self.textfield.autocorrectionType = UITextAutocorrectionType.No
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[scrollView]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["scrollView":scrollView]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[scrollView]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["scrollView":scrollView]))
        
        self.layoutIfNeeded()
    
    }
    
    // Reloads data from datasource and delegate implementations
    
    func reloadData()
    {
        
        UIView.setAnimationsEnabled(false)
        
        // Reset
        self.resetContactBubbleView()
        
        // Update Insets from delegate
        if let insets = dataSource?.insetsForContactBubbleView(self)
        {
            self.contactBubbleInsets = insets
        }
        
        // Set origins
        var scrollViewOriginX: CGFloat = self.contactBubbleInsets.left
        var scrollViewOriginY: CGFloat = self.contactBubbleInsets.top
        
        // Track remaining width
        var remainingWidth = self.scrollView.bounds.width
        let numberOfContactBubble: Int = (dataSource?.numberOfContactBubbleForContactBubbleView(self))!
        
        
        // Add Contact Bubble
        for index in 0..<numberOfContactBubble
        {
            if let contactBubble = dataSource?.contactBubbleView(self, viewForContactBubbleAtIndex: index) as? SVContactBubble
            {
                contactBubble.actionClosure = {(bubble: SVContactBubble) in [self]
                    
                    bubble.removeFromSuperview()
                    self.contactBubbbles.removeAtIndex(self.contactBubbbles.indexOf(bubble)!)
                    self.delegate?.contactBubbleView(self, didDeleteBubbleWithTitle: bubble.titleLabel.text!)
                }
                
                self.setupContactBubble(contactBubble, atIndex: index, offsetX: &scrollViewOriginX, offsetY: &scrollViewOriginY, remainingWidth: &remainingWidth)
            }
        }
        
        // Add Textfield
        
        self.setupTextField(offsetX: &scrollViewOriginX, offsetY: &scrollViewOriginY, remainingWidth: &remainingWidth)
        
        
        // Update scroll view content size
        if self.contactBubbbles.count > 0
        {
            self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.width, scrollViewOriginY + contactBubbleHeight + self.contactBubbleInsets.bottom)
        }
        else
        {
            self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.width, scrollViewOriginY + self.textFieldHeight + self.contactBubbleInsets.bottom)
        }
        
        self.scrollToBottom(animated: false)
        
        // Notify delegate of content size change
        self.delegate?.contactBubbleView(self, contentSizeChanged: self.scrollView.contentSize)
        
        UIView.setAnimationsEnabled(true)
        
    }
    
    
    func resetContactBubbleView()
    {
        for contactBubble in self.contactBubbbles
        {
            contactBubble.removeFromSuperview()
        }
        
        self.textfield.removeFromSuperview()
        
        self.layoutIfNeeded()
        self.contactBubbbles = []
    }
    
    
    // Sets up new contact bubble.
    func setupContactBubble(contactBubble: SVContactBubble, atIndex index:Int, inout offsetX x: CGFloat, inout offsetY y: CGFloat, inout remainingWidth width: CGFloat)
    {
        
        // contact bubble added to collection
        contactBubbbles.append(contactBubble)
        
        contactBubble.tag = index
        
        // Check if token is out of view's bounds, move to new line if so (unless its first token, truncate it)
        if width <= self.contactBubbleInsets.left + contactBubble.frame.width + self.contactBubbleInsets.right && self.contactBubbbles.count > 1
        {
            x = self.contactBubbleInsets.left
            y += contactBubble.frame.height + self.contactBubbleInsets.top
        }
        
        contactBubble.frame = CGRectMake(x + self.contactBubbleInsets.left, y, min(contactBubble.bounds.width, self.scrollView.bounds.width - x - self.contactBubbleInsets.left - self.contactBubbleInsets.right), contactBubble.bounds.height)
        
        self.scrollView.addSubview(contactBubble)
        
        // Update frame data
        x += self.contactBubbleInsets.left + contactBubble.frame.width
        width = self.scrollView.bounds.width - x
        
    }
    
    func updatePlaceholderText(string: String) {
        
        if (string.length == 0) {
            
            self.placeholderLabel.text = self.dataSource?.placeholderTextForContactBubbleView(self)
            self.textfield.text = nil
        }
        else
        {
            self.placeholderLabel.text = nil
        }
    }
    
    
    func setupTextField(inout offsetX x: CGFloat, inout offsetY y: CGFloat, inout remainingWidth width: CGFloat)
    {
        self.textfield.becomeFirstResponder()
        
        self.updatePlaceholderText(self.lastText)
       
        if width >= self.textFieldMinimumWidth
        {
            // Adding textfield in same line with contact bubble
            self.placeholderLabel.frame = CGRectMake(x + 2 * self.contactBubbleInsets.left, y - 2, width - self.contactBubbleInsets.left - 2 * self.contactBubbleInsets.right, self.textFieldHeight)
            
            self.textfield.frame = CGRectMake(x + self.contactBubbleInsets.left, y, width - self.contactBubbleInsets.left - self.contactBubbleInsets.right, self.textFieldHeight)
            width = self.scrollView.bounds.width - x - self.textfield.frame.width
        }
        else
        {
            // Adding textfield in new line
            width = self.scrollView.bounds.width
            
            x = self.contactBubbleInsets.left
            y += self.contactBubbleHeight + self.contactBubbleInsets.top
            
            self.placeholderLabel.frame = CGRectMake(x + 2 * self.contactBubbleInsets.left, y - 2, width - self.contactBubbleInsets.left - 2 * self.contactBubbleInsets.right, self.textFieldHeight)
            
            self.textfield.frame = CGRectMake(x + self.contactBubbleInsets.left, y, width - self.contactBubbleInsets.left - self.contactBubbleInsets.right, self.textFieldHeight)
        }
        
        self.scrollView.addSubview(self.placeholderLabel)
        self.scrollView.addSubview(self.textfield)
    }
    
    
    private func scrollToBottom(animated animated: Bool)
    {
        let bottomPoint = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.height)
        self.scrollView.setContentOffset(bottomPoint, animated: animated)
    }

    
}

class SVBubble: NSObject {
    
}

extension String
{
    var length: Int {
        return characters.count
    }
}
