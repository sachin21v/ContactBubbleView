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

    func insetsForContactBubbleView(_ contactBubbleView: SVContactBubbleView) -> UIEdgeInsets?
    func placeholderTextForContactBubbleView(_ contactBubbleView: SVContactBubbleView) -> String?
    func numberOfContactBubbleForContactBubbleView(_ contactBubbleView: SVContactBubbleView) -> Int
    func contactBubbleView(_ contactBubbleView: SVContactBubbleView, viewForContactBubbleAtIndex index: Int) -> UIView?
}


public protocol SVContactBubbleDelegate
{
    func contactBubbleView(_ contactBubbleView: SVContactBubbleView, didDeleteBubbleWithTitle title: String)
    func contactBubbleView(_ contactBubbleView: SVContactBubbleView, didFinishBubbleWithText text: String)
    func contactBubbleView(_ contactBubbleView: SVContactBubbleView, didChangeText text: String)
    func contactBubbleView(_ contactBubbleView: SVContactBubbleView, contentSizeChanged size: CGSize)
}

// MARK: -UITextFieldDelegate

extension SVContactBubbleView: UITextViewDelegate
{
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if text == doneKey {
            
            self.delegate?.contactBubbleView(self, didFinishBubbleWithText:textfield.text!)
            return false
        }
        
        if text == deleteKey && textView.text == deleteKey {
            
            if let bubble = self.selectedBubble {
                
                bubble.removeFromSuperview()
                self.contactBubbbles.remove(at: self.contactBubbbles.index(of: bubble)!)
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
            let truncatedString = string.substring(to: string.characters.index(before: string.endIndex))
            self.updatePlaceholderText(truncatedString)
            self.delegate?.contactBubbleView(self, didChangeText: truncatedString)
            return true
        }
        
        var string: String = textfield.text!
        string.append(text)
        self.updatePlaceholderText(string)
        self.delegate?.contactBubbleView(self, didChangeText: string)
        return true
    }
}



open class SVContactBubbleView: UIView
{
    
    @IBInspectable open var dataSource: SVContactBubbleDataSource?
    @IBInspectable open var delegate: SVContactBubbleDelegate?
    
    fileprivate var scrollView: UIScrollView = UIScrollView()
    fileprivate var textfield: UITextView = UITextView()
    fileprivate var placeholderLabel: UILabel = UILabel()
    fileprivate var contactBubbbles: [SVContactBubble] = []
    fileprivate var contactBubbleInsets: UIEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5) // Default
    fileprivate var lastText = ""
    
    // MARK: Constants
    var totalBubbles: Int = 0
    var contactBubbleHeight: CGFloat = 30.0
    var textFieldMinimumWidth: CGFloat = 80.0
    var textFieldHeight: CGFloat = 30.0
    
    fileprivate var selectedBubble: SVContactBubble? {
        didSet{
            if let bubble = self.selectedBubble {
                bubble.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    @IBInspectable var contactBubbleViewBorderColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            self.layer.borderColor = self.contactBubbleViewBorderColor.cgColor
        }
    }
    
    

    override open func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.scrollView.backgroundColor = UIColor.clear
        self.scrollView.autoresizesSubviews = false
        self.addSubview(self.scrollView)
        
        self.placeholderLabel.backgroundColor = UIColor.clear
        self.placeholderLabel.textColor = UIColor.lightGray
        
        self.textfield.backgroundColor = UIColor.clear
        self.textfield.textColor = UIColor.black
        self.textfield.font = UIFont.systemFont(ofSize: 16)
        self.textfield.delegate = self
        self.textfield.isScrollEnabled = false
        self.textfield.returnKeyType = UIReturnKeyType.done
        self.textfield.autocorrectionType = UITextAutocorrectionType.no
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[scrollView]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["scrollView":scrollView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[scrollView]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["scrollView":scrollView]))
        
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
                contactBubble.actionClosure = {[weak self](bubble: SVContactBubble) in
                    
                    bubble.removeFromSuperview()
                    self?.contactBubbbles.remove(at: (self?.contactBubbbles.index(of: bubble)!)!)
                    self?.delegate?.contactBubbleView(self!, didDeleteBubbleWithTitle: bubble.titleLabel.text!)
                }
                
                self.setupContactBubble(contactBubble, atIndex: index, offsetX: &scrollViewOriginX, offsetY: &scrollViewOriginY, remainingWidth: &remainingWidth)
            }
        }
        
        // Add Textfield
        
        self.setupTextField(offsetX: &scrollViewOriginX, offsetY: &scrollViewOriginY, remainingWidth: &remainingWidth)
        
        
        // Update scroll view content size
        if self.contactBubbbles.count > 0
        {
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: scrollViewOriginY + contactBubbleHeight + self.contactBubbleInsets.bottom)
        }
        else
        {
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: scrollViewOriginY + self.textFieldHeight + self.contactBubbleInsets.bottom)
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
    func setupContactBubble(_ contactBubble: SVContactBubble, atIndex index:Int, offsetX x: inout CGFloat, offsetY y: inout CGFloat, remainingWidth width: inout CGFloat)
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
        
        contactBubble.frame = CGRect(x: x + self.contactBubbleInsets.left, y: y, width: min(contactBubble.bounds.width, self.scrollView.bounds.width - x - self.contactBubbleInsets.left - self.contactBubbleInsets.right), height: contactBubble.bounds.height)
        
        self.scrollView.addSubview(contactBubble)
        
        // Update frame data
        x += self.contactBubbleInsets.left + contactBubble.frame.width
        width = self.scrollView.bounds.width - x
        
    }
    
    func updatePlaceholderText(_ string: String) {
        
        if (string.length == 0) {
            
            self.placeholderLabel.text = self.dataSource?.placeholderTextForContactBubbleView(self)
            self.textfield.text = nil
        }
        else
        {
            self.placeholderLabel.text = nil
        }
    }
    
    
    func setupTextField(offsetX x: inout CGFloat, offsetY y: inout CGFloat, remainingWidth width: inout CGFloat)
    {
        self.textfield.becomeFirstResponder()
        
        self.updatePlaceholderText(self.lastText)
       
        if width >= self.textFieldMinimumWidth
        {
            // Adding textfield in same line with contact bubble
            self.placeholderLabel.frame = CGRect(x: x + 2 * self.contactBubbleInsets.left, y: y - 2, width: width - self.contactBubbleInsets.left - 2 * self.contactBubbleInsets.right, height: self.textFieldHeight)
            
            self.textfield.frame = CGRect(x: x + self.contactBubbleInsets.left, y: y, width: width - self.contactBubbleInsets.left - self.contactBubbleInsets.right, height: self.textFieldHeight)
            width = self.scrollView.bounds.width - x - self.textfield.frame.width
        }
        else
        {
            // Adding textfield in new line
            width = self.scrollView.bounds.width
            
            x = self.contactBubbleInsets.left
            y += self.contactBubbleHeight + self.contactBubbleInsets.top
            
            self.placeholderLabel.frame = CGRect(x: x + 2 * self.contactBubbleInsets.left, y: y - 2, width: width - self.contactBubbleInsets.left - 2 * self.contactBubbleInsets.right, height: self.textFieldHeight)
            
            self.textfield.frame = CGRect(x: x + self.contactBubbleInsets.left, y: y, width: width - self.contactBubbleInsets.left - self.contactBubbleInsets.right, height: self.textFieldHeight)
        }
        
        self.scrollView.addSubview(self.placeholderLabel)
        self.scrollView.addSubview(self.textfield)
    }
    
    
    fileprivate func scrollToBottom(animated: Bool)
    {
        let bottomPoint = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height)
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
