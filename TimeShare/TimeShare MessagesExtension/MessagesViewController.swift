//
//  MessagesViewController.swift
//  TimeShare MessagesExtension
//
//  Created by David Tan on 7/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    var transitionedViaButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func createNewEvent(_ sender: Any) {
        // switch to expanded mode so the user can start adding dates to a new event
        transitionedViaButton = true
        requestPresentationStyle(.expanded)
    }
    
    // when our app moves between presentation styles we'll get informed in a method called willTransition(to presentationStyle:), which will either be passed .compact or .expanded depending on how the app is changing; when user taps on the Create New Event button, our willTransition() method will get called with .expanded
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // this method is likely to be called multiple times, as user might move in and out of expanded mode as much as they want to
        // therefore, before creating any child view controllers we need to clear out any that already exists, effectively resetting our main controller before we do any fresh work
        
        for child in children {
            // for each child vc that belongs to the current vc, tell the child it's about to have no parent view controller, remove the child's view from its parent, and remove the child itself from its parent
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        // call displayEventViewController() if we are entering expanded mode
        if presentationStyle == .expanded && transitionedViaButton {
            transitionedViaButton = false
            displayEventViewController(conversation: activeConversation, identifier: "CreateEvent")
        } else if presentationStyle == .expanded {
            displayEventViewController(conversation: activeConversation, identifier: "SelectDates")
        }
    }
    
    // problem: the same instance of our MessagesViewController is used in compact and expanded mode, which means we need to display our content directly inside that rather than pushing and popping new view controllers
    // solution: we are going to use child view controllers -> we are going to create an instance of the correct view controller, then place it directly inside the existing MessagesViewController instance
    func displayEventViewController(conversation: MSConversation?, identifier: String) {
        // check if there is an active conversation to work with -> bail out if conversation does not exist
        guard let conversation = conversation else { return }
        
        // create the child view controller using the identifier passed in
        guard let vc = storyboard?.instantiateViewController(identifier: identifier) as? EventViewController else { return }
        
        vc.load(from: conversation.selectedMessage)
        vc.delegate = self
        
        // call addChild on the parent, passing in the child, so that important messages, such as rotation, are forwarded from parent to the child
        addChild(vc)
        
        // give the child's view a meaningful frame within the parent: make it fill our view
        vc.view.frame = view.bounds
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vc.view)
        
        // add auto layout constraints so the child view continues to fill the full view
        vc.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        vc.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // call didMove(toParent:) on the child, to tell the child it has now moved to a new parent view controller
        vc.didMove(toParent: self)
    }
    
    // this method is called from EventViewController
    func createMessages(with dates: [Date], votes: [Int], ourVotes: [Int], description: String) {
        /*
         URLComponents: creates URL object out of an array of URLQueryItem
         URLQueryItem: creates the query part of an url string
         
         MSMessage: responsible for crafting messages: you create it with the URL built using URLComponents, then give it layout instructions
         Layout instructions: provided using MSMessageTemplateLayout, which lets you describe what metadata is attached to your content
         MSSession: responsible for tracking updates to individual messages over time
         
         When you create an MSMessage object, you can choose whether it should be part of a MSSession. If you want it to be interactive – i.e., to change over time as other participants do things with it – then you need a session. If you just want messages to be “fire and forget”, then don’t use one.
         */
        
        /*
         Two things about inserting MSMessages into conversation:
         
         1. You can never send things on behalf of the user. When we insert messages, all we’re doing is adding it to the Messages text entry field ready to send, but we can’t force it out.
         2. Because our messages are set to be interactive – i.e., they change over time – Messages has a built-in mechanism to collapse message changes in a single conversation.
        */
         
        // return our extension to compact mode, since we're finished manipulating dates
        requestPresentationStyle(.compact)
        
        // do a sanity check to ensure we have an active conversation to work with (it is an optional)
        guard let conversation = activeConversation else { return }
        
        // convert all our dates and votes into URLQueryItem objects
        var components = URLComponents()
        var items = [URLQueryItem]()
        
        var userDefaultsKey = ""
        
        for (index, date) in dates.enumerated() {
            // each item is stored as either "date-[number]" or "vote-[number]" so that it's identified uniquely
            // the order of items will be preserved in the array (ie one date item, one vote item, one date item, one vote item, to match the date-vote order)
            let dateItem = URLQueryItem(name: "date-\(index)", value: string(from: date))
            items.append(dateItem)
            userDefaultsKey += dateItem.name + (dateItem.value ?? "")
            
            let voteItem = URLQueryItem(name: "vote-\(index)", value: String(votes[index]))
            items.append(voteItem)
        }
        items.append(URLQueryItem(name: "message-content", value: description))
        
        // wrap URLQueryItems in an URLComponents object
        components.queryItems = items
        
        // check to see if the currently selected message has an active session -> if so, we’ll use it for our changes; if not, we’ll create a new one
        let session = conversation.selectedMessage?.session ?? MSSession()
        
        // create a new MSMessage from the session and assign it the URL we created from our dates and votes
        let message = MSMessage(session: session)
        message.url = components.url
        
        // create a blank, default MSMessageTemplateLayout layout and assign that to the message
        let layout = MSMessageTemplateLayout()
        layout.image = render(dates: dates)
        layout.caption = "I voted"
        message.layout = layout
        
        // save ourVotes array
        let defaults = UserDefaults.standard
        defaults.set(ourVotes, forKey: userDefaultsKey)
        
        // insert the new MSMessage into the current conversation
        conversation.insert(message) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func render(dates: [Date]) -> UIImage {
        // define our 20-point padding
        let inset: CGFloat = 20
        
        // create the attributes for drawing using Dynamic Type so that we respect the user's font choices
        let attributes = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]
        
        // make a single string out of all the dates
        var stringToRender = ""
        
        dates.forEach {
            stringToRender += DateFormatter.localizedString(from: $0, dateStyle: .long, timeStyle: .short) + "\n"
        }
        
        // trim the last line break, then create an attributed string by merging the date string and the attributes
        let trimmed = stringToRender.trimmingCharacters(in: .whitespacesAndNewlines)
        let attributedString = NSAttributedString(string: trimmed, attributes: attributes)
        
        // calculate the size required to draw the attributed string, then add the inset to all edges
        var imageSize = attributedString.size()
        imageSize.width += inset * 2
        imageSize.height += inset * 2
        
        // create an image format (which is the settings for rendering the image) that uses @3x scale on an opaque background
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = 3
        
        // create a renderer at the correct size, using the above format
        let renderer = UIGraphicsImageRenderer(size: imageSize, format: format)
        
        // render a series of instructions to 'image'
        let image = renderer.image { (ctx) in
            // draw a solid white background
            UIColor.white.set()
            ctx.fill(CGRect(origin: CGPoint.zero, size: imageSize))
            
            // now render our text on top, using the insets we created
            attributedString.draw(at: CGPoint(x: inset, y: inset))
        }
        
        // send the resulting image back
        return image
    }
    
    func string(from date: Date) -> String {
        // this method will return a string containing the date passed in, formatted in a specific way, using the UTC timezone, so that everyone sees the same thing
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
        return dateFormatter.string(from: date)
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        // this method is called when the extension is about to move from the inactive to active state (so before anything happens -> activeConversation not set yet)
        if presentationStyle == .expanded {
            // this means when the extension is launched the app starts its life in expanded state rather than compact state
            // therefore the action we have taken here is that we are viewing an event, instead of creating new event
            // as a result we need to instantiate the SelectDates vc, instead of CreateEvent vc
            displayEventViewController(conversation: conversation, identifier: "SelectDates")
        }
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
 // MARK: - Some MSMessagesAppViewController inheritance methods and properties

 /*

 • activeConversation: represents the conversation that is active between the current user and one or more contact. The conversation is the entire history of chats between those people.
 
 • presentationStyle: stores how your view controller is currently being displayed. If you’re in compact mode you occupy a small space where the keyboard normally sits; if you’re in expanded mode you occupy almost all the screen.
 
 • requestPresentationStyle(): lets you request a change from compact to expanded mode, or
 vice versa, depending on user input.
 
 • dismiss(): used when your app is finished working, and you want the keyboard to
 appear.

 */

 // MARK: - When our app runs...

 /*
 
 -   When our app runs, it will start life in the bottom of the screen, with the user’s active conversation above – that’s all the text bubbles between them and one or more contacts.
 
 -   This is compact mode, and by default our app will show the Create New Event button we made earlier.
  
 */



