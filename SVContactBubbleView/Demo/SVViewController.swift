/*
 Copyright (c) 2016 Sachin Verma
 
 SVViewController.swift
 SVContactBubbleView
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class SVViewController: UIViewController
{

    @IBOutlet weak var contactBubbleView: SVContactBubbleView!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var contactBubbleViewHeightConstraint: NSLayoutConstraint!
    
    var cityArray: [SVCity] = []
    var searchedCityArray: [SVCity] = []
    var selectedCityArray: [SVCity] = []
    let contactBubbleViewMinHeight: CGFloat = 40.0
    let contactBubbleViewMaxHeight: CGFloat = 150.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        if let path = NSBundle.mainBundle().pathForResource("Suggestion", ofType: "json")
        {
            
            let cityJsonArray = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: path)!, options: NSJSONReadingOptions()) as? [AnyObject]
            for city in cityJsonArray! {
                let cityToAdd = SVCity(fromDictionary: city as! [String : String])
                cityArray.append(cityToAdd)
            }
            
        }
        
         self.searchedCityArray = self.cityArray
        
        // TokenView
        contactBubbleView.dataSource = self
        contactBubbleView.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        contactBubbleView.reloadData()
    }
    
}



//MARK: SVContactBubbleDataSource

extension SVViewController: SVContactBubbleDataSource
{
    
    func insetsForContactBubbleView(contactBubbleView: SVContactBubbleView) -> UIEdgeInsets?
    {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    func placeholderTextForContactBubbleView(contactBubbleView: SVContactBubbleView) -> String?
    {
        if selectedCityArray.count > 0
        {
            return "Add More..."
        }
        else
        {
            return "Type location"
        }
        
    }
    
    func numberOfContactBubbleForContactBubbleView(contactBubbleView: SVContactBubbleView) -> Int
    {
        return selectedCityArray.count
    }
    
    func contactBubbleView(contactBubbleView: SVContactBubbleView, viewForContactBubbleAtIndex index: Int) -> UIView?
    {
        let city = selectedCityArray[index]
        if let name = city.name
        {
            let contactBubble = SVContactBubble.contactBubbleView(name, image: nil)
            contactBubble?.layoutIfNeeded()
            return contactBubble
        }
        
        return nil
    }
}

//MARK: SVContactBubbleDelegate

extension SVViewController: SVContactBubbleDelegate
{
    func contactBubbleView(contactBubbleView: SVContactBubbleView, didDeleteBubbleWithTitle title: String)
    {
        let searchedArray = selectedCityArray.filter { (city: SVCity) -> Bool in
            return city.name.rangeOfString(title, options: .CaseInsensitiveSearch) != nil
        }
        
        if let found = searchedArray.first
        {
            selectedCityArray.removeAtIndex(selectedCityArray.indexOf(found)!)
            contactBubbleView.reloadData()
        }
        
    }
    
    func contactBubbleView(contactBubbleView: SVContactBubbleView, didChangeText text: String)
    {
        let searchedArray = cityArray.filter { (city: SVCity) -> Bool in
            return city.name.rangeOfString(text, options: .CaseInsensitiveSearch) != nil
        }
        
        self.searchedCityArray = searchedArray
        
        if  text.length == 0  {
            self.searchedCityArray = self.cityArray
        }
        self.contentTableView.reloadData()
    }
    
    
    func contactBubbleView(contactBubbleView: SVContactBubbleView, contentSizeChanged size: CGSize)
    {
        self.contactBubbleViewHeightConstraint.constant = max(self.contactBubbleViewMinHeight,min(size.height, self.contactBubbleViewMaxHeight))
        self.view.layoutIfNeeded()
    }
    
    func contactBubbleView(contactBubbleView: SVContactBubbleView, didFinishBubbleWithText text: String)
    {
        
    }
    
}

//MARK: UITableViewDelegate

extension SVViewController:UITableViewDelegate
{
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let city = searchedCityArray[indexPath.row]
        if selectedCityArray.contains(city) {
            selectedCityArray.removeAtIndex(selectedCityArray.indexOf(city)!)
        }
        else {
            
            selectedCityArray.append(city)
        }
        
        self.searchedCityArray = self.cityArray
        self.contactBubbleView.reloadData()
        self.contentTableView.reloadData()
        
    }
    
}


//MARK: UITableViewDataSource

extension SVViewController:UITableViewDataSource
{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchedCityArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SuggestionCell")!
        
        let city = searchedCityArray[indexPath.row]
        if let name = city.name
        {
            cell.textLabel?.text = name
        }
        
        if selectedCityArray.contains(city) {
            cell.accessoryType = .Checkmark
        }
        else {
            
            cell.accessoryType = .None
        }
        return cell
    }
    
}


class SVCity: SVBubble {
    
    var name: String!
    var city: String!
    
    init(fromDictionary dictionary:[String:String]){
        self.name = dictionary["NAME"]
        self.city = dictionary["CITY"]
    }
    
    
}

