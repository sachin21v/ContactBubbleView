# ContactBubbleView
Easy to use iOS UI Class for a bubble collection similar to the contact in the iOS Message App with customisable bubble . Supports insert , deletion, search for a contact bubble and animation. It supports iOS 8 or later and using Swift 3.0.

How to use:

1. In storyboard just change the custom class of view to SVContactBubbleView.

2.  You can use any view to use as bubble view just subclass your view from SVContactBubble.

3. Implement SVContactBubbleDataSource to configure ContactBubbleView.(like- placeholder text, number of bubble, inset for      contactbubbleview). 

    func placeholderTextForContactBubbleView(_ contactBubbleView: SVContactBubbleView) -> String?
    
    func numberOfContactBubbleForContactBubbleView(_ contactBubbleView: SVContactBubbleView) -> Int
    
    func insetsForContactBubbleView(_ contactBubbleView: SVContactBubbleView) -> UIEdgeInsets?
    
    func contactBubbleView(_ contactBubbleView: SVContactBubbleView, viewForContactBubbleAtIndex index: Int) -> UIView?


4. Implement SVContactBubbleDelegate to add action on ContactBubbleView(like- deleting particular bubble , changing size of content view,    perform action on change in input from user) 

    func contactBubbleView(_ contactBubbleView: SVContactBubbleView, didDeleteBubbleWithTitle title: String)
    
    func contactBubbleView(_ contactBubbleView: SVContactBubbleView, didChangeText text: String)
    
    func contactBubbleView(_ contactBubbleView: SVContactBubbleView, contentSizeChanged size: CGSize)
    
    func contactBubbleView(_ contactBubbleView: SVContactBubbleView, didFinishBubbleWithText text: String)

