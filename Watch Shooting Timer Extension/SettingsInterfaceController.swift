//
//  SettingsInterfaceController.swift
//  Watch Shooting Timer Extension
//
//  Created by Admin on 26.12.2020.
//  Copyright © 2020 Thousand soft. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class SettingsInterfaceController: WKInterfaceController {
    
    private var session = WCSession.default
    
    @IBOutlet weak var titleEnableSwitch: WKInterfaceSwitch!
    @IBOutlet weak var blackBackSwitch: WKInterfaceSwitch!
    @IBOutlet weak var whiteTargetSwitch: WKInterfaceSwitch!
    
    
    @IBAction func whiteTargetSwitchChange(_ value: Bool) {
        if isReachable() {
            session.sendMessage(["isWhiteTarget":value], replyHandler: nil, errorHandler: nil)
            print("Sended")
        }
        else {
            print("Iphone is not reachable")
        }
    }
    
    @IBAction func blackBackSwitchChange(_ value: Bool) {
        if isReachable() {
            session.sendMessage(["blackBack":value], replyHandler: nil, errorHandler: nil)
            print("Sended")
        }
        else {
            print("Iphone is not reachable")
        }
    }
    
    
    @IBAction func titleEnabledSwitchChange(_ value: Bool) {
        if isReachable() {
            session.sendMessage(["title":value], replyHandler: nil, errorHandler: nil)
            print("Sended")
        }
        else {
            print("Iphone is not reachable")
        }
    }
    
    private func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
    func sendSettingsScreenStatus(){
        if isReachable() {
            session.sendMessage(["settings":"opened"], replyHandler: nil, errorHandler: nil)
            print("Sended")
        }
        else {
            print("Iphone is not reachable")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if (message["isWhiteList"] as? Bool == true) {
            DispatchQueue.main.async {
                self.whiteTargetSwitch.setOn(true)
            }
         
        }
        else if (message["isWhiteList"] as? Bool == false){
            DispatchQueue.main.async {
                self.whiteTargetSwitch.setOn(false)
            }
        }
        if (message["isBlackBack"] as? Bool == true) {
            DispatchQueue.main.async {
                self.blackBackSwitch.setOn(true)
            }
         
        }
        else if (message["isBlackBack"] as? Bool == false){
            DispatchQueue.main.async {
                self.blackBackSwitch.setOn(false)
            }
        }
        if (message["titleEnabled"] as? Bool == true) {
            DispatchQueue.main.async {
                self.titleEnableSwitch.setOn(true)
            }
         
        }
        else if (message["titleEnabled"] as? Bool == false){
            DispatchQueue.main.async {
                self.titleEnableSwitch.setOn(false)
            }
        }
    }
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if isSuported(){
            session.delegate = self
            session.activate()
            sendSettingsScreenStatus()
        }
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
extension SettingsInterfaceController:WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    
}
