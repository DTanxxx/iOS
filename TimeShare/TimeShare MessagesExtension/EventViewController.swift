//
//  EventViewController.swift
//  TimeShare MessagesExtension
//
//  Created by David Tan on 7/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import Messages

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var datePicker: UIDatePicker!
    
    var dates = [Date]()  // stores the list of dates that are on offer
    var allVotes = [Int]()  // stores the list of votes from everyone in the group
    var ourVotes = [Int]()  // stores the list of votes from 'us', that 'we' intend to cast ('we' here means the user who is creating the event)
    var messageText = ""
    var isViewingEvent = false
    
    weak var delegate: MessagesViewController!  // used to pass messages from this vc to MessagesViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
  
    @IBAction func saveSelectedDates(_ sender: Any) {
        // check for message text
        if messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            messageText = "Event creator did not include description"
        }
        
        delegate.createMessages(with: dates, votes: allVotes, ourVotes: ourVotes, description: messageText)
    }
    
    @IBAction func addDate(_ sender: Any) {
        // add the current date from date picker to the dates array
        dates.append(datePicker.date)
        // add 0 to the allVotes array because the new date has no votes
        allVotes.append(1)
        // add 1 to the ourVotes array so the event creator votes for it by default
        ourVotes.append(1)
        
        // use insertRows() to insert a row in the table view using animation
        let newIndexPath = IndexPath(row: dates.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        
        // use scrollToRow() to scroll the new row into view
        tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        
        // use flashScrollIndicators() to flash the scroll bars so the user knows something has changed
        tableView.flashScrollIndicators()
    }
    
    // to avoid confusion, this method is called from MessagesViewController, when the user is viewing an event (rather than creating one)
    func load(from message: MSMessage?) {
        // do a full check for every optionality in the message passed in
        guard let message = message else { return }
        guard let messageURL = message.url else { return }
        guard let urlComponents = URLComponents(url: messageURL, resolvingAgainstBaseURL: false) else { return }
        guard let queryItems = urlComponents.queryItems else { return }
        
        isViewingEvent = true
        var userDefaultsKey = ""
        
        // reverse the process in createMessages() to retrieve the values from queryItems
        for item in queryItems {
            if item.name.hasPrefix("date-") {
                dates.append(date(from: item.value ?? ""))
                userDefaultsKey += item.name + (item.value ?? "")
            } else if item.name.hasPrefix("vote-") {
                let voteCount = Int(item.value ?? "") ?? 0
                allVotes.append(voteCount)
            } else if item.name.contains("message-content") {
                messageText = item.value ?? ""
            }
        }
        
        // grab ourVotes from user default
        let defaults = UserDefaults.standard
        var reserveVotesArray = [Int]()
        for _ in allVotes { reserveVotesArray.append(0) }
        ourVotes = defaults.object(forKey: userDefaultsKey) as? [Int] ?? reserveVotesArray
    }
    
    func date(from string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
        return dateFormatter.date(from: string) ?? Date()
    }
    
    // MARK: - table view data source
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let textField = UITextField()
        textField.delegate = self
        
        textField.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)
        textField.placeholder = "Please briefly explain this event..."
        textField.text = messageText
        textField.font = .preferredFont(forTextStyle: .title2)
        textField.textColor = .darkGray
        textField.textAlignment = .center
        
        if !isViewingEvent {
            textField.isUserInteractionEnabled = true
        } else if isViewingEvent {
            textField.isUserInteractionEnabled = false
        }
        
        return textField
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // dequeue a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Date", for: indexPath)
        
        // pull out the corresponding date and format it neatly
        let date = dates[indexPath.row]
        cell.textLabel?.text = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .short)
        
        // add a checkmark if we voted for this date
        if ourVotes[indexPath.row] == 1 {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        // add a vote count if other people voted for this date
        if allVotes[indexPath.row] > 0 {
            cell.detailTextLabel?.text = "Votes: \(allVotes[indexPath.row])"
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
        
        /*
         Note: we made the CreateEvent table use the Basic cell style, and the SelectDates table use the Subtitle cell style. This is because when you’re creating a new event it doesn’t have any votes yet, but thanks to the power of optional chaining we don’t need to worry whether there’s a subtitle text label or not – we can just try to set it, and Swift will silently ignore the call if it doesn’t exist.
         */
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect the row that was tapped; we don't want it to stay selected (for aesthetic reasons -- we want the tap to show shading, but when we lift the finger we want the row to de-shade)
        tableView.deselectRow(at: indexPath, animated: true)
        
        // find the cell that was tapped and query whether it has a checkmark right now
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                // remove the checkmark
                cell.accessoryType = .none
                // set the corresponding element in ourVotes to 0
                ourVotes[indexPath.row] = 0
                allVotes[indexPath.row] -= 1
            } else {
                // add a checkmark
                cell.accessoryType = .checkmark
                // set the corresponding element in ourVotes to 1
                ourVotes[indexPath.row] = 1
                allVotes[indexPath.row] += 1
            }
        }
    }
    
    // MARK: - text field
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // set messageText and resign the keyboard
        messageText = textField.text ?? ""
        textField.resignFirstResponder()
        return true
    }
    
    
}
