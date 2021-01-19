//
//  ViewController.swift
//  Shooting Timer
//
//  Created by Admin on 03.12.2020.
//  Copyright © 2020 Thousand soft. All rights reserved.
//

import UIKit
import AVFoundation
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var startButton: UIBarButtonItem!
    @IBOutlet weak var navigationBat: UINavigationItem!
    @IBOutlet weak var timingSegmentedControl: UISegmentedControl!
    var isRedLight = false
    var isGreenLigth = false
    var targetIsWhite = true
    var backgroundIsBlack = true
    var timer = Timer()
    var shotsCount = 0
    var isStarted = false
    var timingInSeconds = 3.1
    var repeatShooting = 5
    var defaults = UserDefaults.standard
    var showTitles = true
    var shotSoundEffect: AVAudioPlayer?
    var wcSession: WCSession!
    var endlessRepeat = false
    //private var session = WCSession.default
    let shotSoundPath = Bundle.main.path(forResource: "shot_sound", ofType: "wav")!
    let squeakSoundPath = Bundle.main.path(forResource: "beep-09", ofType: "wav")!
    lazy var shotSoundUrl = URL(fileURLWithPath: shotSoundPath)
    lazy var squeakSoundUrl = URL(fileURLWithPath: squeakSoundPath)
    
    
    @IBOutlet weak var greenLight: UIImageView!
    @IBOutlet weak var redLight: UIImageView!
    
    @IBOutlet weak var sizeSlider: UISlider!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var targetWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var targetHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var targetWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var greenLightHeight: NSLayoutConstraint!
    
    @IBOutlet weak var greenLightWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var redLightHeight: NSLayoutConstraint!
    
    @IBOutlet weak var redLightWidth: NSLayoutConstraint!
    
    
    
    
    @IBAction func sizeSliderValueChange(_ sender: UISlider) {
        distanceLabel.text = String(format: "%.01f", sizeSlider.value) + "m"
        defaults.set(sizeSlider.value, forKey: "sizeSliderValue")
        let sideLengthInCM = sizeSlider.value / 2 / 50 * 100
        let sideLenght = sideLengthInCM * 128
        targetWidth.constant = CGFloat(sideLenght)
        targetHeight.constant = CGFloat(sideLenght)
        defaults.set(sideLenght, forKey: "targetSideLenght")
        let lightSideLenght = sideLengthInCM / 5.5 * 128
        defaults.set(lightSideLenght, forKey: "lightSideLenght")
        greenLightHeight.constant = CGFloat(lightSideLenght)
        greenLightWidth.constant = CGFloat(lightSideLenght)
        redLightHeight.constant = CGFloat(lightSideLenght)
        redLightWidth.constant = CGFloat(lightSideLenght)
        mainView.layoutIfNeeded()
    }
    
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        self.wcSession.activate()
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["startButton"] as? String == "pressed" {
            DispatchQueue.main.async {
                self.startPress(self.startButton)
            }
            
        }
        
        if message["settings"] as? String == "opened" {
            DispatchQueue.main.async {
                self.wcSession.sendMessage(["isWhiteList":self.defaults.bool(forKey: "White List")], replyHandler: nil, errorHandler: nil)
                self.wcSession.sendMessage(["isBlackBack":self.defaults.bool(forKey: "Background")], replyHandler: nil, errorHandler: nil)
                self.wcSession.sendMessage(["titleEnabled":self.defaults.bool(forKey: "Titles")], replyHandler: nil, errorHandler: nil)
            }
            
        }
        
        if message["isWhiteTarget"] as? Bool == true {
            DispatchQueue.main.async {
                self.targetIsWhite = true
                self.setSettingsDefaults()
                self.defaults.set(true, forKey: "White List")
            }
        }
        else if message["isWhiteTarget"] as? Bool == false{
            DispatchQueue.main.async {
                self.targetIsWhite = false
                self.setSettingsDefaults()
                self.defaults.set(false, forKey: "White List")
            }
        }
        
        if message["blackBack"] as? Bool == true {
            DispatchQueue.main.async {
                self.backgroundIsBlack = true
                self.setSettingsDefaults()
                self.defaults.set(true, forKey: "Background")
            }
        }
        else if message["blackBack"] as? Bool == false{
            DispatchQueue.main.async {
                self.backgroundIsBlack = false
                self.setSettingsDefaults()
                self.defaults.set(false, forKey: "Background")
            }
        }
        
        if message["title"] as? Bool == true {
            DispatchQueue.main.async {
                self.showTitles = true
                self.defaults.set(true, forKey: "Titles")
            }
        }
        else if message["title"] as? Bool == false{
            DispatchQueue.main.async {
                self.showTitles = false
                self.defaults.set(false, forKey: "Titles")
            }
        }
        if message["watchApp"] as? String == "started" {
            DispatchQueue.main.async {
                self.wcSession.sendMessage(["iosApp":"show"], replyHandler: nil, errorHandler: nil)
            }
        }
        
    }
    
    
    @IBAction func timingSegmentedControl(_ sender: UISegmentedControl) {
       setMainTitle()
    }
    func setMainTitle(){
        if (timingSegmentedControl.selectedSegmentIndex == 0){
                    timingInSeconds = 3.1
                    repeatShooting = 5
                   navigationItem.title = "Center Fire"
               }
               else if(timingSegmentedControl.selectedSegmentIndex == 1){
                   timingInSeconds = 4.1
                   repeatShooting = 1
                   navigationItem.title = "Rapid Fire 4 Sec"
               }
               else if(timingSegmentedControl.selectedSegmentIndex == 2){
                   timingInSeconds = 6.1
                   repeatShooting = 1
                   navigationItem.title = "Rapid Fire 6 Sec"
               }
               else if(timingSegmentedControl.selectedSegmentIndex == 3){
                   timingInSeconds = 8.1
                   repeatShooting = 1
                   navigationItem.title = "Rapid Fire 8 Sec"
               }
    }
    
    @IBAction func startPress(_ sender: UIBarButtonItem) {
        if (!isStarted) {
            if (defaults.bool(forKey: "EndlessRepeat") == false){
                RapidFireSingle()
            }
            else {
                RapidFireEndless()
            }
            startButton.title = "Stop"
            startButton.tintColor = UIColor.red
            isStarted = true
            timingSegmentedControl.isEnabled = false
            UIApplication.shared.isIdleTimerDisabled = true
            timingSegmentedControl.isHidden = true
            settingsButton.isEnabled = false
            showTitle()
            wcSession.sendMessage(["exStatus":"started"], replyHandler: nil, errorHandler: nil)
        }
        else {
            offAllLights()
            shotsCount = 0
            isRedLight = false
            isGreenLigth = false
            startButton.title = "Start"
            startButton.tintColor = UIColor.systemGreen
            isStarted = false
            timingSegmentedControl.isEnabled = true
            UIApplication.shared.isIdleTimerDisabled = false
            timingSegmentedControl.isHidden = false
            settingsButton.isEnabled = true
            setMainTitle()
            wcSession.sendMessage(["exStatus":"stopped"], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func redLightOn() {
        redLight.image = UIImage(named: "red_on")
    }
    
    func redLightOff() {
        redLight.image = UIImage(named: "red_off")
    }
    
    func greenLightOn() {
        greenLight.image = UIImage(named: "green_on")
    }
    
    func greenLightOff() {
        greenLight.image = UIImage(named: "green_off")
    }
    
    @objc func RapidFireEndless(){
        showTitle()
        RapidFireSingle()
    }
    
    
    func RapidFireSingle() {
        if (defaults.bool(forKey: "SqueakSound")){
            playShotSound(url: squeakSoundUrl)
        }
        redLightOn()
        changeLightToGreen()
        //offAllLights()
    }
    
    func changeLightToGreen() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(timerChangeToGreen), userInfo: nil, repeats: false)
    }
    
    @objc func timerChangeToGreen() {
        greenLightOn()
        redLightOff()
        shotsCount+=1
        timer.invalidate()
        changeLightToRed()
    }
    
    func changeLightToRed() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timingInSeconds, target: self, selector: #selector(timerChangeToRed), userInfo: nil, repeats: false)
    }
    
    
    
    @objc func timerChangeToRed() {
        if (defaults.bool(forKey: "ShotSound")){
            playShotSound(url: shotSoundUrl)
        }
        greenLightOff()
        redLightOn()
        timer.invalidate()
        if (shotsCount < repeatShooting){
            changeLightToGreen()
        }
        else {
            if (defaults.bool(forKey: "EndlessRepeat") == false){
                offAllLights()
                shotsCount = 0
            }
            else {
                navigationItem.title = "Repeat after " + String(format: "%.0f", defaults.double(forKey: "DelayTime")) + " sec"
                greenLightOff()
                redLightOff()
                shotsCount = 0
                repeatRapidFire()
            }
        }
    }
    
    func repeatRapidFire() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: defaults.double(forKey: "DelayTime"), target: self, selector: #selector(RapidFireEndless), userInfo: nil, repeats: false)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = UIColor.darkGray
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemGreen]
        defaultSettings()
        readDefaultsSettings()
        setSettingsDefaults()
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
        DispatchQueue.main.async {
            self.wcSession.sendMessage(["iosApp":"show"], replyHandler: nil, errorHandler: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(hiding), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hiding), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showing), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    @objc func hiding () {
        wcSession.sendMessage(["iosApp":"hide"], replyHandler: nil, errorHandler: nil)
    }
    
    @objc func showing () {
        wcSession.sendMessage(["iosApp":"show"], replyHandler: nil, errorHandler: nil)
    }
    
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        
        
    }
    
    func offAllLights() {
        greenLightOff()
        redLightOn()
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timerOffLights), userInfo: nil, repeats: false)
    }
    
    @objc func timerOffLights() {
        if (defaults.bool(forKey: "SqueakSound")){
            playShotSound(url: squeakSoundUrl)
        }
        greenLightOff()
        redLightOff()
        startButton.title = "Start"
        startButton.tintColor = UIColor.systemGreen
        isStarted = false
        timingSegmentedControl.isEnabled = true
        timer.invalidate()
        UIApplication.shared.isIdleTimerDisabled = false
        timingSegmentedControl.isHidden = false
        settingsButton.isEnabled = true
        setMainTitle()
        wcSession.sendMessage(["exStatus":"stopped"], replyHandler: nil, errorHandler: nil)
    }
    
    
    
    func readDefaultsSettings(){
        targetIsWhite = defaults.bool(forKey: "White List")
        backgroundIsBlack = defaults.bool(forKey: "Background")
        showTitles = defaults.bool(forKey: "Titles")
    }
    
    func setSettingsDefaults(){
        setTargetImage(state: targetIsWhite)
        setBackgroundColor(state: backgroundIsBlack)
        redLightWidth.constant = CGFloat(defaults.double(forKey: "lightSideLenght"))
        redLightHeight.constant = CGFloat(defaults.double(forKey: "lightSideLenght"))
        greenLightWidth.constant = CGFloat(defaults.double(forKey: "lightSideLenght"))
        greenLightHeight.constant = CGFloat(defaults.double(forKey: "lightSideLenght"))
        targetHeight.constant = CGFloat(defaults.double(forKey: "targetSideLenght"))
        targetWidth.constant = CGFloat(defaults.double(forKey: "targetSideLenght"))
        sizeSlider.value = defaults.float(forKey: "sizeSliderValue")
        distanceLabel.text = String(format: "%.01f", defaults.float(forKey: "sizeSliderValue")) + "m"
    }
    
    func defaultSettings(){
        UserDefaults.standard.register(defaults: ["sizeSliderValue" : 2.5])
        UserDefaults.standard.register(defaults: ["targetSideLenght" : 320])
        UserDefaults.standard.register(defaults: ["lightSideLenght" : 58])
        
    }
    
    
    func setTargetImage(state: Bool) {
        if (state){
            targetImageView.image = UIImage(named: "vactor_target_q")
        }
        else {
            targetImageView.image = UIImage(named: "vector_target_yellow")
        }
    }
    
    func setBackgroundColor(state: Bool) {
        if (state){
            mainView.backgroundColor = UIColor.black
        }
        else {
            mainView.backgroundColor = UIColor.white
        }
    }
    
    func showTitle(){
        if (!showTitles){
            navigationItem.title = ""
        }
        else {
            setMainTitle()
        }
    }
    
    func playShotSound(url: URL) {
        do{
            shotSoundEffect = try AVAudioPlayer(contentsOf: url)
            shotSoundEffect?.play()
        } catch {
            print("Can`t find file")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        readDefaultsSettings()
        setSettingsDefaults()
        wcSession.sendMessage(["iosApp":"show"], replyHandler: nil, errorHandler: nil)
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

