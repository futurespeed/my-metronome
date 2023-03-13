//
//  ViewController.swift
//  MyMetronome
//
//  Created by 高景新 on 2021/7/15.
//

import UIKit
//import WebKit
import AudioToolbox

class ViewController: UIViewController {
    var infoView: UIView?
    var infoLabel: UILabel?
    var settingView: UIView?
    var settingButton: UIButton?
    var stickLabel: UILabel?
    var stickItemLabel: UILabel?
    var startStopButton: UIButton?
    var settingConfirmButton: UIButton?
    var bgScopeWiew: UIImageView?
    var bgLayer: CAGradientLayer?
    var step1Input: UITextField?
    var step2Input: UITextField?
    var speedInput: UITextField?
    
    var timer: Timer?
    var step1: Int = 1
    var step2: Int = 4
    var stepCount: Int = 0
    var speed: Int = 60 // times every minute
    var fps: Int = 38 // Frame Per Second
    var maxDegree : Float = 72
    var beginDegree: Float = 0
    var currentDegree: Float = 0
    var currentDirection: Bool = true
    var playTink: Bool = false
    var isRunning: Bool = false
    var isSlowSetting: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBg()
        setupInfo()
        setupSetting()
        //setupStick()
        setupButton()
        
        resetDegree()
        refreshStick()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let w = self.view.frame.width
        let h = self.view.frame.height
        
        let padding: CGFloat = 30
        var safeW: CGFloat = w
        if(w > h){
            safeW = h
        }
        let contentWidth = safeW - padding * 2
        let contentX = (w - contentWidth) / 2
        
        infoView!.frame = CGRect(x: contentX, y: h / 8, width: contentWidth, height: infoView!.frame.height)
        
        //stickLabel!.frame = CGRect(x: (w - stickLabel!.frame.width) / 2, y: h / 2, width: stickLabel!.frame.width, height: stickLabel!.frame.height)
        let stickHeight = h / 4
        let stickWidth: CGFloat = stickHeight / 16
        
        setupStick(x: (w - stickWidth) / 2, y: h / 2, w: stickWidth, h: stickHeight)
        
        bgLayer!.frame = self.view.frame
        
        let bgScopeHeight = stickHeight - stickWidth
        let bgScopeWidth = bgScopeHeight * (1000/954.96)
        bgScopeWiew!.frame = CGRect(x: (w - bgScopeWidth)/2, y: h / 2 - bgScopeHeight / 2, width: bgScopeWidth, height: bgScopeHeight)
        
        startStopButton!.frame = CGRect(x: (w - startStopButton!.frame.width) / 2, y: h / 4 * 3, width: startStopButton!.frame.width, height: startStopButton!.frame.height)
    }
    
    func setupBg(){
//        let svgPath = Bundle.main.path(forResource: "scope", ofType: "svg")
//        bgScopeWebWiew = WKWebView(frame: CGRect(x: 30, y: 200, width: 200, height: 200))
//        bgScopeWebWiew!.load(URLRequest(url: URL(fileURLWithPath: svgPath!)))
//        bgScopeWebWiew!.evaluateJavaScript("var svg = document.querySelector('svg');svg.style.width='100%';svg.style.height='100%';")
//        self.view.addSubview(bgScopeWebWiew!)
        
        bgLayer = CAGradientLayer()
        bgLayer!.colors = [getColor(hexStr: "FFFFFF").cgColor, getColor(hexStr: "015478").cgColor]
        bgLayer!.locations = [0,1.0]
        bgLayer!.startPoint = CGPoint(x: 0, y: 0)
        bgLayer!.endPoint = CGPoint(x: 0, y: 1.0)
        bgLayer!.frame = self.view.frame
        self.view.layer.addSublayer(bgLayer!)
        
        bgScopeWiew = UIImageView(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "scope", ofType: "png")!))
        self.view.addSubview(bgScopeWiew!)
    }
    
    func setupInfo(){
        infoView = UIView(frame: CGRect(x: 200, y: 80, width: 300, height: 60))
        infoView!.layer.masksToBounds = true
        infoView!.layer.cornerRadius = 16
        infoView!.backgroundColor = getColor(hexStr: "EEEEEE")
        
        infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 60))
        infoLabel!.textColor = getColor(hexStr: "888888")
        infoLabel!.textAlignment = .center
        infoLabel!.text = "Step: " + String(step1) + "/" + String(step2) + "      " + "Speed: " + String(speed)
        infoView!.addSubview(infoLabel!)
        
        settingButton = UIButton(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        settingButton!.setBackgroundImage(UIImage(contentsOfFile:  Bundle.main.path(forResource: "setting", ofType: "png")!), for: .normal)
//        settingButton!.backgroundColor = .systemYellow
//        settingButton!.layer.cornerRadius = settingButton!.frame.width / 2
        settingButton!.addTarget(self, action: #selector(toggleSetting(_:)), for: .touchUpInside)//FIXME not working
        infoView!.isUserInteractionEnabled = true
        infoView!.addSubview(settingButton!)
        self.view.addSubview(infoView!)
    }
    
    func setupSetting(){
        settingView = UIView(frame: CGRect(x: 20, y: 10, width: 300 - 60, height: 300))
        settingView!.isHidden = true
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: settingView!.frame.width, height: 30))
        titleLabel.text = "Setting"
        titleLabel.textColor = getColor(hexStr: "888888")
        titleLabel.textAlignment = .center
        settingView?.addSubview(titleLabel)
        
        let stepLabel = UILabel(frame: CGRect(x: 0, y: 60, width: settingView!.frame.width, height: 30))
        stepLabel.text = "Step"
        stepLabel.textColor = getColor(hexStr: "888888")
        settingView?.addSubview(stepLabel)
        
        let speedLabel = UILabel(frame: CGRect(x: 0, y: 180, width: settingView!.frame.width, height: 30))
        speedLabel.text = "Speed"
        speedLabel.textColor = getColor(hexStr: "888888")
        settingView?.addSubview(speedLabel)
        
        step1Input = UITextField(frame: CGRect(x: 100, y: 60, width: 50, height: 30))
        step1Input!.text = String(self.step1)
        settingView!.addSubview(step1Input!)

        step2Input = UITextField(frame: CGRect(x: 160, y: 60, width: 50, height: 30))
        step2Input!.text = String(self.step2)
        settingView!.addSubview(step2Input!)
        
        speedInput = UITextField(frame: CGRect(x: 100, y: 180, width: 50, height: 30))
        speedInput!.text = String(self.speed)
        settingView!.addSubview(speedInput!)
        
        settingConfirmButton = UIButton(frame: CGRect(x: 210, y: 240, width: 40, height: 30))
        settingConfirmButton!.layer.cornerRadius = settingConfirmButton!.frame.height / 2
        settingConfirmButton!.backgroundColor = .systemBlue
        settingConfirmButton!.setTitle("ok", for: .normal)
        settingConfirmButton!.addTarget(self, action: #selector(settingConfirmButtonTapped), for: .touchUpInside)
        settingView!.addSubview(settingConfirmButton!)

        settingView!.isUserInteractionEnabled = true
        infoView!.addSubview(settingView!)
    }
    
    func setupStick(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat){
        if(stickItemLabel != nil){
            stickItemLabel!.removeFromSuperview()
            stickItemLabel = nil
        }
        if(stickLabel != nil){
            stickLabel!.removeFromSuperview()
            stickLabel = nil
        }
        
        stickLabel = UILabel(frame: CGRect(x: x, y: y, width: w, height: h))
        stickLabel!.backgroundColor = getColor(hexStr: "FACD91")
        stickLabel!.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        stickLabel!.transform = CGAffineTransform(rotationAngle: CGFloat(toRadian(degree: Float(currentDegree))))
        
        stickItemLabel = UILabel(frame: CGRect(x: -w/2, y: h/3*2, width: w*2, height: w*2))
        stickItemLabel?.backgroundColor = getColor(hexStr: "F59A23")
        stickLabel!.addSubview(stickItemLabel!)
        if(isSlowSetting){
            stickLabel!.isHidden = true
        }
        self.view.addSubview(stickLabel!)
    }
    
    func setupButton() {
        startStopButton = UIButton(frame: CGRect(x: 300, y: 300, width: 100, height: 100))
        startStopButton!.layer.cornerRadius = startStopButton!.frame.width / 2
        startStopButton!.backgroundColor = .systemBlue
        startStopButton!.setTitle("start", for: .normal)
        startStopButton!.addTarget(self, action: #selector(startStopButtonTapped), for: .touchUpInside)
        self.view.addSubview(startStopButton!)
    }
    
    @objc
    func startStopButtonTapped() {
        if (isRunning) {
            timer?.invalidate()
            timer = nil
            stepCount = 0
            resetDegree()
            refreshStick()
            startStopButton!.setTitle("start", for: .normal)
            startStopButton!.backgroundColor = .systemBlue
        } else {
            timer = Timer.scheduledTimer(timeInterval: self.getTimeInterval(), target: self, selector: #selector(timerTriggered(timer:)), userInfo: nil, repeats: true)
            startStopButton!.setTitle("stop", for: .normal)
            startStopButton!.backgroundColor = .systemRed
        }
        isRunning = !isRunning
    }
    
    @objc
    func settingConfirmButtonTapped(){
        self.step1 = Int(String(step1Input!.text!))!
        self.step2 = Int(String(step2Input!.text!))!
        self.speed = Int(String(speedInput!.text!))!
        infoLabel!.text = "Step: " + String(step1) + "/" + String(step2) + "      " + "Speed: " + String(speed)
        toggleSetting(settingButton!)
    }
    
    @objc
    func timerTriggered(timer: Timer) {
        // every fps
        
        if(currentDirection){
            currentDegree += (Float(speed) / Float(fps))
        }else{
            currentDegree -= (Float(speed) / Float(fps))
        }
        refreshStick()
        
        // play tink
        if(!playTink && (currentDirection && currentDegree >= 180
                            || !currentDirection && currentDegree <= 180
        )){
            stepCount+=1
            stepCount %= step2
            if(stepCount % step2 == 0){
                AudioServicesPlaySystemSound(1104)
            }else{
                AudioServicesPlaySystemSound(1103)
            }
            playTink = true
        }
        
        if(currentDegree >= beginDegree + maxDegree){
            currentDirection = !currentDirection
            playTink = false
        }
        if(currentDegree <= beginDegree){
            currentDirection = !currentDirection
            playTink = false
        }
    }
    func refreshStick(){
        //print(currentDegree)
        stickLabel?.transform = CGAffineTransform(rotationAngle: CGFloat(toRadian(degree: Float(currentDegree))))
    }
    
    func resetDegree(){
        currentDirection = true
        beginDegree = 180 - maxDegree / 2
        currentDegree = beginDegree + maxDegree / 2
    }
    
    func getTimeInterval() -> Double {
        return Double(1.0) / Double(fps)
    }
    
    @objc
    func toggleSetting(_ sender: UIButton){
        self.view.bringSubviewToFront(infoView!)
        infoView?.bringSubviewToFront(settingButton!)
        var newFrame = infoView!.frame
        if(isSlowSetting){
//            let animation = CAKeyframeAnimation(keyPath: "transform")
//            animation.duration = 1.5
//            animation.values = [CATransform3DMakeScale(1, 4, 1)]
//            infoLabel!.layer.add(animation, forKey: "transform")
            newFrame.size.height = 60
            infoLabel!.isHidden = false
            stickLabel!.isHidden = false
            settingView!.isHidden = true
        }else{
            newFrame.size.height = 300
            infoLabel!.isHidden = true
            stickLabel!.isHidden = true
            settingView!.isHidden = false
            step1Input!.text = String(self.step1)
            step2Input!.text = String(self.step2)
            speedInput!.text = String(self.speed)
        }
        UIView.animate(withDuration: 0.25) {
            self.infoView!.frame =  newFrame
        }
        isSlowSetting = !isSlowSetting
    }
    
    
    func toRadian(degree: Float)->Float{
        return degree / 180.0 * Float(CGFloat.pi)
    }
    
    func getColor(hexStr: String)->UIColor{
        let r:CGFloat = CGFloat(Float(Int(hexStr.prefix(2),radix: 16)!)/255.0)
        let g:CGFloat = CGFloat(Float(Int(hexStr.suffix(4).prefix(2),radix: 16)!)/255.0)
        let b:CGFloat = CGFloat(Float(Int(hexStr.suffix(2),radix: 16)!)/255.0)
        let a:CGFloat = 1
        return UIColor(displayP3Red: r, green: g, blue: b, alpha: a)
    }
}

