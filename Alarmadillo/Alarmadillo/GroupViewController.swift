//
//  GroupViewController.swift
//  Alarmadillo
//
//  Created by David Tan on 28/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class GroupViewController: UITableViewController, UITextFieldDelegate {

    var group: Group!
    let playSoundTag = 1001
    let enabledTag = 1002
    weak var rootVC: ViewController?
    var alarmToReload: IndexPath?
    var alarmAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlarm))
        title = group.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = alarmToReload {
            if alarmAdded {
                alarmAdded = false
                tableView.insertRows(at: [indexPath], with: .none)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
            alarmToReload = nil
            saveAlarmToReload()
        }
    }
    
    func saveAlarmToReload() {
        let defaults = UserDefaults.standard
        defaults.set(alarmToReload?.row ?? -1, forKey: "indexPathAlarm")
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        // if the changed switch has the tag playSoundTag then we update the 'playSound' property of the current group, otherwise we update the 'enabled' property
        if sender.tag == playSoundTag {
            group.playSound = sender.isOn
        } else {
            group.enabled = sender.isOn
        }
        
        save()
    }
    
    @objc func addAlarm() {
        let newAlarm = Alarm(name: "Name this alarm", caption: "Add an optional description", time: Date(), image: "", changed: true)
        group.alarms.append(newAlarm)
        
        performSegue(withIdentifier: "EditAlarm", sender: newAlarm)
        
        save()
    }
    
    @objc func save() {
        // "post the command 'save' to the rest of the app", so that any part of the app that wants to be notified when a save has been requested will get that message delivered
        // this is similar to using a delegate
        NotificationCenter.default.post(name: Notification.Name("save"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let alarmToEdit: Alarm
        
        if sender is Alarm {
            // called from addAlarm()
            alarmToEdit = sender as! Alarm
            alarmToReload = IndexPath(row: group.alarms.count-1, section: 1)
            alarmAdded = true
        } else {
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            alarmToEdit = group.alarms[selectedIndexPath.row]
            alarmToReload = selectedIndexPath
        }
        
        if let alarmViewController = segue.destination as? AlarmViewController {
            alarmViewController.alarm = alarmToEdit
        }
    }
    
    // this method is responsible for loading all the cells in the first section
    func createGroupCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            // this is the first cell: editing the name of the group
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditableText", for: indexPath)
            
            // look for the text field inside the cell...
            if let cellTextField = cell.viewWithTag(1) as? UITextField {
                // ...then give it the group name
                cellTextField.text = group.name
            }
            
            return cell
            
        case 1:
            // this is the "play sound" cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Switch", for: indexPath)
            
            // look for both the label and the switch
            if let cellLabel = cell.viewWithTag(1) as? UILabel, let cellSwitch = cell.viewWithTag(2) as? UISwitch {
                // configure the cell with correct settings
                cellLabel.text = "Play Sound"
                cellSwitch.isOn = group.playSound
                
                // set the switch up with the playSoundTag tag so we know which one was changed later on
                cellSwitch.tag = playSoundTag
            }
            
            return cell
            
        default:
            // if we're anything else, we must be the "enabled" switch, which is basically the same as the "play sound" switch
            let cell = tableView.dequeueReusableCell(withIdentifier: "Switch", for: indexPath)
            
            if let cellLabel = cell.viewWithTag(1) as? UILabel, let cellSwitch = cell.viewWithTag(2) as? UISwitch {
                // obviously it's configured a little differently below
                cellLabel.text = "Enabled"
                cellSwitch.isOn = group.enabled
                cellSwitch.tag = enabledTag
            }
            
            return cell
        }
    }
    
    // MARK: - text field methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // update the name property of current group
        group.name = textField.text!
        // set the name to navigation bar title
        title = group.name
        
        save()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // dismiss the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // return nothing if we're the first section
        if section == 0 { return nil }
        
        // if we're still here, it means we're the second section - do we have at least 1 alarm?
        if group.alarms.count > 0 { return "Alarms" }
        
        // if we're still here we have 0 alarms, so return nothing
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // give section one 3 rows, and section two as many rows as there are alarms
        if section == 0 {
            return 3  // 3 cells, using 2 prototype cells -> one text field, two switches
        } else {
            return group.alarms.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // pass the hard work onto a different method if we're in the first section
            return createGroupCell(for: indexPath, in: tableView)
        } else {
            // if we're here it means we're an alarm, so pull out a RightDetail cell for display
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetail", for: indexPath)
            
            // pull out the correct alarm from the alarms array
            let alarm = group.alarms[indexPath.row]
            
            // use the alarm to configure the cell, drawing on DateFormatter's localized date parsing
            cell.textLabel?.text = alarm.name
            cell.detailTextLabel?.text = DateFormatter.localizedString(from: alarm.time, dateStyle: .none, timeStyle: .short)
            
            return cell
        }
    }
    
    // this method makes certain rows editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // only allow editing for rows in second section
        return indexPath.section == 1
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // MARK: - remove the request for that alarm
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [group.alarms[indexPath.row].id])
        
        group.alarms.remove(at: indexPath.row)
        // when you delete a row, table view only deletes the row from the second section (since only rows in second section are allowed for editing)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        save()
    }
    
    // to fix the problem of having the custom-designed cells having text that's further to the left than the built-in cells (also need to adjust the constraints in storyboard to 'Relative to Margins')
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = true
        cell.contentView.preservesSuperviewLayoutMargins = true
    }
    
}
