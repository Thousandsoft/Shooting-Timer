//
//  InterfaceController.swift
//  Watch Shooting Timer Extension
//
//  Created by Admin on 19.12.2020.
//  Copyright © 2020 Thousand soft. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WKCrownDelegate {
    
    @IBOutlet weak var configButton: WKInterfaceButton!
    var isStarted = false
    var distanceValue = 0.5
    
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        let newValue = distanceValue + (rotationalDelta)
        if newValue < 0.5 {
            distanceValue = 0.5
        } else if newValue > 2.5 {
            distanceValue = 2.5
        } else {
            distanceValue = newValue
        }
        session.sendMessage(["distance":distanceValue], replyHandler: nil, errorHandler: nil)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    @IBOutlet weak var startButton: WKInterfaceButton!
    
    private var session = WCSession.default
    
    
    @IBAction func startPressed() {
        
        
        if isReachable() {
            session.sendMessage(["startButton":"pressed"], replyHandler: nil, errorHandler: nil)
            print("Sended")
        }
        else {
            print("Iphone is not reachable")
        }
            
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if (message["exStatus"] as? String == "stopped") {
            DispatchQueue.main.async {
                self.startButton.setBackgroundColor(UIColor.green)
                self.startButton.setTitle("Start")
                self.configButton.setEnabled(true)
                self.crownSequencer.focus()
            }
         
        }
        else if(message["exStatus"] as? String == "started"){
            DispatchQueue.main.async {
                self.startButton.setBackgroundColor(UIColor.red)
                self.startButton.setTitle("Stop")
                self.configButton.setEnabled(false)
                self.crownSequencer.resignFocus()
            }
        }
        
        if (message["iosApp"] as? String == "show") {
            DispatchQueue.main.async {
                self.startButton.setEnabled(true)
                self.statusLabel.setTextColor(UIColor.green)
                self.configButton.setEnabled(true)
                self.crownSequencer.focus()
            }
        }
        else if (message["iosApp"] as? String == "hide") {
            DispatchQueue.main.async {
                self.startButton.setEnabled(false)
                self.statusLabel.setTextColor(UIColor.red)
                self.configButton.setEnabled(false)
                self.crownSequencer.resignFocus()
            }
        }
        
        if let distance = message["distanceValue"] as? Double{
            DispatchQueue.main.async {
            self.distanceValue = distance
            }
        }
        
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if isSuported(){
            session.delegate = self
            session.activate()
            session.sendMessage(["watchApp":"started"], replyHandler: nil, errorHandler: nil)
        }
        //crownSequencer.focus()
        crownSequencer.delegate = self
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        /*self.startButton.setEnabled(false)
        self.statusLabel.setTextColor(UIColor.red)
        self.configButton.setEnabled(false)*/
        if isSuported(){
            session.delegate = self
            session.activate()
            session.sendMessage(["watchApp":"started"], replyHandler: nil, errorHandler: nil)
        }
        
        /*if (!isReachable()){
            statusLabel.setTextColor(UIColor.red)
            self.startButton.setEnabled(false)
        }
        else {
            statusLabel.setTextColor(UIColor.green)
            self.startButton.setEnabled(true)
        }*/
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
}
extension InterfaceController:WCSessionDelegate {
    
}
