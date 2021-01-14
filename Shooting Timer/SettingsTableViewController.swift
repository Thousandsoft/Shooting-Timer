//
//  SettingsTableViewController.swift
//  Shooting Timer
//
//  Created by Admin on 08.12.2020.
//  Copyright © 2020 Thousand soft. All rights reserved.
//

import UIKit
import WatchConnectivity


class SettingsTableViewController: UITableViewController, UITextFieldDelegate, WCSessionDelegate {
    
    

    @IBOutlet weak var swowTitlesSwitch: UISwitch!
    @IBOutlet weak var blackBackgroundSwitch: UISwitch!
    @IBOutlet weak var whiteSwitch: UISwitch!
    @IBOutlet weak var squeakSoundButton: UIButton!
    @IBOutlet weak var shotSoundButton: UIButton!
    @IBOutlet weak var settingsTableView: UITableView!
    
    @IBOutlet weak var endlessRepeatSwitch: UISwitch!
    
    @IBOutlet weak var repeatDelayCell: UITableViewCell!
    
    @IBOutlet weak var delayTimeLabel: UITextField!
    
    var shotSoundIsEnabled = false
    var squeakSoundIsEnabled = false
    var defaults = UserDefaults.standard
    var whiteList = false
    var isBlackBackground = false
    var showTitles = false
    
    
    var wcSession: WCSession!
    
    
    
    @IBAction func endlessRepeatSwitchChange(_ sender: UISwitch) {
        if (endlessRepeatSwitch.isOn == true){
            repeatDelayCell.isHidden = false
            defaults.setValue(true, forKey: "EndlessRepeat")
            defaults.setValue(Double(delayTimeLabel.text!), forKey: "DelayTime")
        }
        else {
            repeatDelayCell.isHidden = true
            defaults.setValue(false, forKey: "EndlessRepeat")
        }
    }
    
    @IBAction func showTitlesSwitchChange(_ sender: UISwitch) {
        if (showTitles){
            showTitles = !showTitles
            defaults.set(false, forKey: "Titles")
            wcSession.sendMessage(["Title":"hide"], replyHandler: nil, errorHandler: nil)
        }
        else {
            showTitles = !showTitles
            defaults.set(true, forKey: "Titles")
            wcSession.sendMessage(["Title":"show"], replyHandler: nil, errorHandler: nil)
        }
    }
    
    @IBAction func backgroundSwitch(_ sender: UISwitch) {
        if (isBlackBackground) {
            isBlackBackground = !isBlackBackground
            defaults.set(false, forKey: "Background")
            wcSession.sendMessage(["isBlackBack":false], replyHandler: nil, errorHandler: nil)
        }
        else {
            isBlackBackground = !isBlackBackground
            defaults.set(true, forKey: "Background")
            wcSession.sendMessage(["isBlackBack":true], replyHandler: nil, errorHandler: nil)
        }
    }
    @IBAction func whiteListSwitch(_ sender: UISwitch) {
        if (whiteList) {
            whiteList = !whiteList
            defaults.set(false, forKey: "White List")
        }
        else {
            whiteList = !whiteList
            defaults.set(true, forKey: "White List")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delayTimeLabel.delegate = self
        self.addDoneToolbar()
        readDefaultsSettings()
        setSettingsState()
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
        tableView.tableFooterView = UIView()
        
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["blackBack"] as? Bool == true {
            DispatchQueue.main.async {
                self.blackBackgroundSwitch.isOn = true
                self.defaults.set(true, forKey: "Background")
            }
            
        }
        
        else if (message["blackBack"] as? Bool == false){
            DispatchQueue.main.async {
                self.blackBackgroundSwitch.isOn = false
                self.defaults.set(false, forKey: "Background")
            }
        }
        if message["settings"] as? String == "opened" {
            DispatchQueue.main.async {
                self.wcSession.sendMessage(["isWhiteList":self.defaults.bool(forKey: "White List")], replyHandler: nil, errorHandler: nil)
                self.wcSession.sendMessage(["isBlackBack":self.defaults.bool(forKey: "Background")], replyHandler: nil, errorHandler: nil)
                self.wcSession.sendMessage(["titleEnabled":self.defaults.bool(forKey: "Titles")], replyHandler: nil, errorHandler: nil)
            }
            
        }
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 3
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        defaults.setValue(Double(delayTimeLabel.text!), forKey: "DelayTime")
        print("Returned!!!")
        return false
    }
    
    @IBAction func shotSoundPressed(_ sender: UIButton) {
        changeSoundState(button: shotSoundButton, state: shotSoundIsEnabled)
        if (shotSoundIsEnabled){
            defaults.set(true, forKey: "ShotSound")
        }
        else {
            defaults.set(false, forKey: "ShotSound")
        }
        shotSoundIsEnabled = !shotSoundIsEnabled
        
    }
    @IBAction func squeakSoundPressed(_ sender: UIButton) {
        changeSoundState(button: squeakSoundButton, state: squeakSoundIsEnabled)
        if (squeakSoundIsEnabled){
            defaults.set(true, forKey: "SqueakSound")
        }
        else {
            defaults.set(false, forKey: "SqueakSound")
        }
        squeakSoundIsEnabled = !squeakSoundIsEnabled
    }
    
    func changeSoundState(button: UIButton, state: Bool){
        if (state) {
            button.setImage(UIImage(systemName: "speaker.3.fill"), for: .normal)
            button.tintColor = UIColor.systemGreen
        }
        else {
            button.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
            button.tintColor = UIColor.systemRed
        }
    }
    
    func readDefaultsSettings() {
        whiteList = defaults.bool(forKey: "White List")
        isBlackBackground = defaults.bool(forKey: "Background")
        showTitles = defaults.bool(forKey: "Titles")
    }
    func setSettingsState(){
        whiteSwitch.setOn(whiteList, animated: false)
        blackBackgroundSwitch.setOn(isBlackBackground, animated: false)
        swowTitlesSwitch.setOn(showTitles, animated: false)
        endlessRepeatSwitch.setOn(defaults.bool(forKey: "EndlessRepeat"), animated: false)
        if (defaults.bool(forKey: "EndlessRepeat") == true){
            repeatDelayCell.isHidden = false
        }
        else {
            repeatDelayCell.isHidden = true
        }
        delayTimeLabel.text = String(format: "%.0f", defaults.double(forKey: "DelayTime"))
        shotSoundIsEnabled = defaults.bool(forKey: "ShotSound")
        changeSoundState(button: shotSoundButton, state: shotSoundIsEnabled)
        squeakSoundIsEnabled = defaults.bool(forKey: "SqueakSound")
        changeSoundState(button: squeakSoundButton, state: squeakSoundIsEnabled)
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func addDoneToolbar(onDone: (target: Any, action: Selector)? = nil){
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar : UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)]
        toolbar.sizeToFit()
        self.delayTimeLabel.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
        self.delayTimeLabel.resignFirstResponder()
        defaults.setValue(Double(delayTimeLabel.text!), forKey: "DelayTime")
    }
    
}

