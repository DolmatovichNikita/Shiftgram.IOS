import UIKit
import Speech
import ROGoogleTranslate

class AudioViewController: UIViewController {
    
    public var name = String()
    public var conversationName = String()
    public var friendLanguage = String()
    private var language = (Locale.preferredLanguages.first?.parseLanguage())!
    private let userId = String(UserEntity().getUserId())
    private var timer: Timer?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: Locale.preferredLanguages.first!))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()
    private var speechText = ""
    private let synthezier = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        self.initControls()
        self.initChat()
        self.initAudioCalling()
    }
    
    @objc private func tapGestureRecroding(gesture: UITapGestureRecognizer) {
        Constants.refs.databaseRoot.child(self.conversationName + "audio").removeValue()
        Constants.refs.databaseRoot.child(self.conversationName + "audioCalling").removeValue()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.navigateToVideo()
    }
    
    @objc private func sendText(gesture: UITapGestureRecognizer) {
        let user = self.userId
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            let userDM = UserDataManager()
            let frId = (Int(self.conversationName)! / Int(self.userId)!)
            userDM.getFriendLanguage(id: frId) { (value) in
                let ref = Constants.refs.databaseRoot.child(self.conversationName + "audio").childByAutoId()
                
                if value == self.language {
                    let message = ["sender_id": user, "ownText": self.speechText, "transText": self.speechText]
                    
                    ref.setValue(message)
                    self.speechText = ""
                } else {
                    let params = ROGoogleTranslateParams(source: self.language,
                                                         target: value,
                                                         text:   self.speechText)
                    let translator = ROGoogleTranslate()
                    translator.apiKey = "AIzaSyA03pGAne7Bz9t8Y-ZeW0K-TVM15vEZYLQ"
                    translator.translate(params: params) { (value) in
                        if !value.isEmpty {
                            let message = ["sender_id": user, "ownText": self.speechText, "transText": value]
                            
                            ref.setValue(message)
                            self.speechText = ""
                        }
                    }
                }
            }
            let button = self.view.viewWithTag(42) as! UIButton
            button.setImage(UIImage(named: "recording"), for: .normal)
        } else {
            self.startRecording()
            let button = self.view.viewWithTag(42) as! UIButton
            button.setImage(UIImage(named: "inRecording"), for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func initControls() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 4)
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(30)
        label.textColor = UIColor.white
        label.text = name
        
        let labelContacting = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        labelContacting.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 4 + 100)
        labelContacting.textAlignment = NSTextAlignment.center
        labelContacting.font = labelContacting.font.withSize(30)
        labelContacting.textColor = UIColor.white
        labelContacting.text = "Contacting ..."
        labelContacting.tag = 1
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        cancelButton.center = CGPoint(x: self.view.frame.width / 2 - 100 , y: self.view.frame.height - 100)
        cancelButton.backgroundColor = UIColor.red
        cancelButton.setImage(UIImage(named: "endCall"), for: .normal)
        cancelButton.layer.cornerRadius = 27
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecroding(gesture:)))
        cancelButton.addGestureRecognizer(tapGesture)
        
        let muteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        muteButton.center = CGPoint(x: self.view.frame.width / 2 + 100, y: self.view.frame.height - 100)
        muteButton.backgroundColor = UIColor.white
        muteButton.setImage(UIImage(named: "recording"), for: .normal)
        muteButton.layer.cornerRadius = 27
        muteButton.tag = 42
        let tapGestureRecord = UITapGestureRecognizer(target: self, action: #selector(sendText(gesture:)))
        muteButton.addGestureRecognizer(tapGestureRecord)
        
        self.view.addSubview(label)
        self.view.addSubview(labelContacting)
        self.view.addSubview(cancelButton)
        self.view.addSubview(muteButton)
    }
    
    private func initAudioSession() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    private func initChat() {
        let user = self.userId
        let query = Constants.refs.databaseRoot.child(self.conversationName + "audio").queryLimited(toLast: 10)
        
        _ = query.observe(.childAdded, with: { snapshot in
            if let data = snapshot.value as? [String: String] {
                let id = data["sender_id"]
                let text = id != user ? data["transText"] : nil
                if text != nil && !(text?.isEmpty)! && id != String(self.userId) {
                    self.synthezier.continueSpeaking()
                    let utterance = AVSpeechUtterance(string: text!)
                    utterance.voice = AVSpeechSynthesisVoice(language: Locale.preferredLanguages.first?.parseLanguage())
                    utterance.volume = 1.0
                    utterance.rate = 0.4
                    self.synthezier.speak(utterance)
                }
            }
        })
    }
    
    private func initAudioCalling() {
        let query = Constants.refs.databaseRoot.child(self.conversationName + "audioCalling").queryLimited(toLast: 10)
        
        _ = query.observe(.childAdded, with: { (snapshot) in
            if let data = snapshot.value as? [String: String] {
                let id = data["sender_id"]
                
                if id != nil && !(id?.isEmpty)! {
                    let label = self.view.viewWithTag(1) as! UILabel
                    
                    label.text = String(format: "%02i:%02i", 0, 0)
                    var counter = 0
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                        counter += 1
                        var minute = 0
                        var seconds = 0
                        
                        if counter > 60 {
                            minute = counter / 60
                            seconds = counter % 60
                        } else {
                            seconds = counter
                        }
                        label.text = String(format: "%02i:%02i", minute, seconds)
                    })
                }
            }
        })
    }
    
    private func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        self.initAudioSession()
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                self.speechText = (result?.bestTranscription.formattedString)!
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
}
