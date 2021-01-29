//
//  ViewController.swift
//  Alarmadillo
//
//  Created by David Tan on 28/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    var groups = [Group]()
    var alarmID: String?
    var indexPathToReload: IndexPath?
    var addedGroup = false
    var groupFromNotif = false
    var deleteFromNotif = false
    var removePictureFromNotif = false
    var indexPathToReloadAlarms: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 20)!]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        title = "Alarmadillo"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGroup))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Groups", style: .plain, target: nil, action: nil)
        
        // add an observer for the "save" notification that gets posted from GroupViewController and AlarmViewController, so that when save() is called in these view controllers, this main ViewController will be notified and its save() will be called -> saves the groups array, which includes the changes applied to its groups or alarms
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: Notification.Name("save"), object: nil)
    }
    
    // MARK: - saving and loading data
    
    func saveIndexPathToReloadAlarms() {
        let defaults = UserDefaults.standard
        defaults.set(indexPathToReloadAlarms?.row ?? -1, forKey: "indexPathAlarm")
    }
    
    func loadIndexPathToReloadAlarms() {
        let defaults = UserDefaults.standard
        let rowNum = defaults.integer(forKey: "indexPathAlarm")
        if rowNum != -1 {
            indexPathToReloadAlarms = IndexPath(row: rowNum, section: 1)
        } else {
            indexPathToReloadAlarms = nil
        }
    }
    
    func saveDeleteFromNotif() {
        let defaults = UserDefaults.standard
        defaults.set(deleteFromNotif, forKey: "delete")
    }
    
    func loadDeleteFromNotif() {
        let defaults = UserDefaults.standard
        deleteFromNotif = defaults.bool(forKey: "delete")
    }
    
    func saveIndexPathToReload() {
        let defaults = UserDefaults.standard
        defaults.set(indexPathToReload?.row ?? -1, forKey: "indexPath")
    }
    
    func loadIndexPathToReload() {
        let defaults = UserDefaults.standard
        let rowNum = defaults.integer(forKey: "indexPath")
        if rowNum != -1 {
            indexPathToReload = IndexPath(row: rowNum, section: 0)
        } else {
            indexPathToReload = nil
        }
    }
    
    @objc func save() {
        // save the data by writing to disk
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
            
            let data = try NSKeyedArchiver.archivedData(withRootObject: groups, requiringSecureCoding: false)
            try data.write(to: path)
        } catch {
            print("Failed to save")
        }
        
        // update our system notifications every time we make changes to alarms (so alarms ring at the right time)
        updateNotifications()
    }
    
    func load() {
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
            
            let data = try Data(contentsOf: path)
            groups = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Group] ?? [Group]()  // create an empty array if there isn't one saved
        } catch {
            print("Failed to load")
        }
        
        if let indexPath = indexPathToReload {
            if !deleteFromNotif {
                if addedGroup {
                    addedGroup = false
                    tableView.insertRows(at: [indexPath], with: .none)
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
                indexPathToReload = nil
                saveIndexPathToReload()
            } else {
                viewWillAppear(true)
            }
        }
    }
    
    // MARK: - notifications delegate methods
    
    // this is called when a notification has come in while the app is running
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // only show the message -> exclude the sound
        completionHandler([.alert])
    }
    
    // this is called when the user acts on a notification -> in this case the actions can be displaying a group, deleting a group, or renaming a group
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // when notification comes in, we need to pull out the userInfo dictionary for the group ID
        let userInfo = response.notification.request.content.userInfo
        
        if let groupID = userInfo["group"] as? String, let alarmID = userInfo["alarm"] as? String {
            // if we got a group ID, we're good to go
            // read the actionIdentifer value to see what action the user tapped
            switch response.actionIdentifier {
            // besides the three actions that we have registered in SceneDelegate, there is also an UNNotificationDefaultActionIdentifier (sent to you when the user swipes on the notification to unlock their device), and an UNNotificationDismissActionIdentifier (sent to you when the user dismisses the notification)
                
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock; do nothing
                print("Default identifier")
                
            case UNNotificationDismissActionIdentifier:
                // the user dismissed the alert; do nothing
                print("Dismiss identifier")
                
            case "show":
                // the user asked to see the group, so call display()
                display(group: groupID)
                break
                
            case "destroy":
                // the user asked to destroy the group, so call destroy()
                destroy(group: groupID)
                break
                
            case "removePicture":
                removePictureFor(group: groupID, alarm: alarmID)
                break
                
            case "rename":
                // the user asked to rename the group, so safely unwrap their text response and call rename()
                // if the “rename” action is triggered, then didReceive() will get called with a specific type of notification response called UNTextInputNotificationResponse. This is a subclass of a regular notification response, and provides a userText property that tells you what text the user entered
                if let textResponse = response as? UNTextInputNotificationResponse {
                    rename(group: groupID, newName: textResponse.userText)
                }
                break
                
            default:
                break
            }
        }
        
        // you need to call the completion handler when you're done
        completionHandler()
    }
    
    func display(group groupID: String) {
        _ = navigationController?.popToRootViewController(animated: false)  // we don't want to manipulate our data while the user is several screens deep, because they might later try to rename an alarm in a group that no longer exists
        
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
                
            let data = try Data(contentsOf: path)
            groups = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Group] ?? [Group]()  // create an empty array if there isn't one saved
        } catch {
            print("Failed to load")
        }
        
        // loop through all the groups and find the one that was used to display notification
        for group in groups {
            if group.id == groupID {
                // call performSegue() using this group as the 'sender' parameter
                groupFromNotif = true
                performSegue(withIdentifier: "EditGroup", sender: group)
                return
            }
        }
    }
    
    func destroy(group groupID: String) {
        _ = navigationController?.popToRootViewController(animated: false)
        
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
                
            let data = try Data(contentsOf: path)
            groups = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Group] ?? [Group]()  // create an empty array if there isn't one saved
        } catch {
            print("Failed to load")
        }

        for (index, group) in groups.enumerated() {
            if group.id == groupID {
                // remove the requests for each alarm in that group
                let center = UNUserNotificationCenter.current()
                var identifiers = [String]()
                for alarm in group.alarms {
                    identifiers.append(alarm.id)
                }
                center.removePendingNotificationRequests(withIdentifiers: identifiers)
                
                indexPathToReload = IndexPath(row: index, section: 0)
                deleteFromNotif = true
                groups.remove(at: index)
                break
            }
        }
        
        saveDeleteFromNotif()
        loadDeleteFromNotif()
        saveIndexPathToReload()
        loadIndexPathToReload()
        save()
        load()  // to reload table view
    }
    
    func removePictureFor(group groupID: String, alarm alarmID: String) {
        _ = navigationController?.popToRootViewController(animated: false)
        
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
                
            let data = try Data(contentsOf: path)
            groups = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Group] ?? [Group]()  // create an empty array if there isn't one saved
        } catch {
            print("Failed to load")
        }
        
        for (index, group) in groups.enumerated() {
            if group.id == groupID {
                for (index, alarm) in group.alarms.enumerated() {
                    if alarm.id == alarmID {
                        alarm.image = ""
                        indexPathToReloadAlarms = IndexPath(row: index, section: 1)
                        removePictureFromNotif = true
                        break
                    }
                }
                indexPathToReload = IndexPath(row: index, section: 0)
                break
            }
        }
        
        saveIndexPathToReloadAlarms()
        loadIndexPathToReloadAlarms()
        saveIndexPathToReload()
        loadIndexPathToReload()
        save()
        load()
    }
    
    func rename(group groupID: String, newName: String) {
        _ = navigationController?.popToRootViewController(animated: false)
        
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
                
            let data = try Data(contentsOf: path)
            groups = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Group] ?? [Group]()  // create an empty array if there isn't one saved
        } catch {
            print("Failed to load")
        }
        
        for (index, group) in groups.enumerated() {
            if group.id == groupID {
                group.name = newName
                indexPathToReload = IndexPath(row: index, section: 0)
                break
            }
        }
        
        saveIndexPathToReload()
        loadIndexPathToReload()
        save()
        load()
    }
    
    // MARK: - creating notifications
    
    func updateNotifications() {
        // request permission to show notifications
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { [unowned self]
            (granted, error) in
            if granted {
                // schedule the notifications using our current alarms
                self.createNotifications()
            }
        }
    }
    
    // responsible for removing any notifications currently scheduled and going through all the groups and alarms to see which need to be scheduled
    func createNotifications() {
        let center = UNUserNotificationCenter.current()
        
        // remove alarm if alarm.hasChanged; remove the pending notification for that request and schedule a new one

        // loop through every group, ignoring those groups that aren't enabled
        for group in groups {
            
            // remove pending notifications for disabled groups
            if !group.enabled {
                var identifiers = [String]()
                for alarm in group.alarms {
                    alarm.hasChanged = true
                    identifiers.append(alarm.id)
                }
                center.removePendingNotificationRequests(withIdentifiers: identifiers)
            }
            
            
            guard group.enabled == true else { continue }
            
            // loop through every alarm in the enabled groups and call createNotificationRequest() for each one
            for alarm in group.alarms {
                if alarm.hasChanged {
                    alarm.hasChanged = false
                    // alarm has been changed
                    center.removePendingNotificationRequests(withIdentifiers: [alarm.id])
                    let notification = createNotificationRequest(group: group, alarm: alarm)
                    // pass the UNNotificationRequest objects returned to the user notification center for delivery
                    center.add(notification) { (error) in
                        if let error = error {
                            print("Error scheduling notification: \(error)")
                        }
                    }
                }
            }
        }
        
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
            
            let data = try NSKeyedArchiver.archivedData(withRootObject: groups, requiringSecureCoding: false)
            try data.write(to: path)
        } catch {
            print("Failed to save")
        }
    }
    
    // responsible for creating the actual individual notifications
    func createNotificationRequest(group: Group, alarm: Alarm) -> UNNotificationRequest {
        // start by creating the content for the notification
        let content = UNMutableNotificationContent()
        
        // assign the alarm's name and caption
        content.title = alarm.name
        content.body = alarm.caption
        
        // give it an identifier so we can attach custom buttons to the notification later on
        if alarm.image.count > 0 {
            content.categoryIdentifier = "alarmWithPictures"
        } else {
            content.categoryIdentifier = "alarm"
        }
        
        // attach the group ID and alarm ID for this alarm (as context information -> this information will be sent back to us when the notification is triggered)
        content.userInfo = ["group": group.id, "alarm": alarm.id]
        
        // if the user requested a sound for this group, attach their default alert sound
        if group.playSound {
            content.sound = UNNotificationSound.default
        }
        
        // use createNotificationAttachments to attach a picture for this alert if there is one
        content.attachments = createNotificationAttachments(alarm: alarm)
        
        // get a Calendar object ready to pull out date components
        let cal = Calendar.current
        
        // pull out the hour and minute components from this alarm's Date
        var dateComponents = DateComponents()
        dateComponents.hour = cal.component(.hour, from: alarm.time)
        dateComponents.minute = cal.component(.minute, from: alarm.time)
        
        // create a trigger matching those date components, set to repeat
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        
        // combine the content and the trigger to create a notification request
        // the 'identifier' parameter is used to check, edit or remove a specific notification; for now we don't care about this, so we use UUID string
        
        // using alarm.id as request's identifier
        let request = UNNotificationRequest(identifier: alarm.id, content: content, trigger: trigger)
        
        // pass that object back to createNotifications() for scheduling
        return request
    }
    
    // responsible for adding the user's image to the notification, if one is set
    func createNotificationAttachments(alarm: Alarm) -> [UNNotificationAttachment] {
        // return if there is no image to attach
        guard alarm.image.count > 0 else { return [] }
        
        let fm = FileManager.default
        
        do {
            // get the full path to the alarm image
            let imageURL = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            
            // MARK: - create a temporary filename to store a copy of the alert image -> this is needed because when you attach an image to a notification, it gets moved into a separate location so that it can be guaranteed to exist when shown
            // this means you cannot just use the same file we placed into the documents directory, because it will get moved away and thus lost
            let copyURL = Helper.getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).jpg")
            
            // copy the alarm image to the temporary filename
            try fm.copyItem(at: imageURL, to: copyURL)
            
            // create an attachment from the temporary filename, giving it a random identifier
            let attachment = try UNNotificationAttachment(identifier: UUID().uuidString, url: copyURL)
            
            // return the attachment back to createNotificationRequest()
            return [attachment]
        } catch {
            print("Failed to attach alarm image: \(error)")
            return []
        }
    }
    
    // MARK: - make the newly added group appear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadDeleteFromNotif()
        if deleteFromNotif {
            // delete the group
            deleteFromNotif = false
            saveDeleteFromNotif()
            if let indexPath = indexPathToReload {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                removePictureFromNotif = false
                indexPathToReload = nil
                saveIndexPathToReload()
                loadIndexPathToReload()
            }
        }
        load()
    }
    
    // MARK: - segue
    
    @objc func addGroup() {
        let newGroup = Group(name: "Name this group", playSound: true, enabled: false, alarms: [])
        groups.append(newGroup)
        save()
        
        // call performSegue(), and pass the new group in as the 'sender' parameter
        performSegue(withIdentifier: "EditGroup", sender: newGroup)
    }
    
    // when a segue is about to happen, this prepare() method gets called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let groupToEdit: Group
        
        if sender is Group {
            // we were called from addGroup() or notification action (display); use what it sent us
            groupToEdit = sender as! Group
            if !groupFromNotif && !removePictureFromNotif{
                indexPathToReload = IndexPath(row: groups.count-1, section: 0)
                addedGroup = true
            } else if groupFromNotif {
                groupFromNotif = false
            }
        } else {
            // we were called by a table view cell; figure out which group we're attached to and send that
            // this step is required because we have made the table view cells to call performSegue() when they are tapped, and since this call is automatic (ie not done in code), the 'sender' parameter in performSegue() is of type Any?, and therefore we cannot assign sender to groupToEdit straight away -> we need to find the correct group in the groups array and assign that to groupToEdit
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            groupToEdit = groups[selectedIndexPath.row]
            indexPathToReload = selectedIndexPath
        }
        
        // unwrap our destination from the segue
        if let groupViewController = segue.destination as? GroupViewController {
            // give it whatever group we decided above
            groupViewController.group = groupToEdit
            groupViewController.rootVC = self
            
            if removePictureFromNotif {
                removePictureFromNotif = false
                groupViewController.alarmToReload = indexPathToReloadAlarms
            }
        }
    }
    
    // MARK: - table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let center = UNUserNotificationCenter.current()
        var identifiers = [String]()
        for alarm in groups[indexPath.row].alarms {
            identifiers.append(alarm.id)
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        
        groups.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        save()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Group", for: indexPath)
        
        let group = groups[indexPath.row]
        cell.textLabel?.text = group.name
        
        if group.enabled {
            // if enabled, make name color black
            cell.textLabel?.textColor = UIColor.black
        } else {
            // otherwise, make name color red
            cell.textLabel?.textColor = UIColor.red
        }
        
        // set the detail text label, taking into account singular/plural
        if group.alarms.count == 1 {
            cell.detailTextLabel?.text = "1 alarm"
        } else {
            cell.detailTextLabel?.text = "\(group.alarms.count) alarms"
        }
        
        return cell
    }

}
