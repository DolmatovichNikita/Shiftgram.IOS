import UIKit
import JSQMessagesViewController
import ROGoogleTranslate
import AVFoundation
import Speech
import CallKit

class ChatViewController: JSQMessagesViewController, AVAudioRecorderDelegate, SFSpeechRecognizerDelegate {

    public var conversationName = String()
    public var friendLanguage = String()
    private var messages = [JSQMessage]()
    private let userId = UserEntity().getUserId()
    private var language = (Locale.preferredLanguages.first?.parseLanguage())!
    
    var audioRecorder: AVAudioRecorder?
    private var timer = Timer()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: Locale.preferredLanguages.first!))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var speechText = ""
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.lightGray)
    }()
    
    lazy var rightBarButtonItem: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "microphone"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        let gestureRecgnizer = UILongPressGestureRecognizer(target: self, action: #selector (longPressedButton(tapGestureRecognizer:)))
        button.addGestureRecognizer(gestureRecgnizer)
        return button
    }()
    
    private func initChat() {
        senderId = String(userId)
        senderDisplayName = String(userId)
        title = "Chat: \(senderDisplayName!)"
        
        let query = Constants.refs.databaseRoot.child(self.conversationName).queryLimited(toLast: 10)
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            if let data = snapshot.value as? [String: String] {
                let id = data["sender_id"]
                let name = data["name"]
                let audioUrl = data["audio"]
                if audioUrl != nil &&  !audioUrl!.isEmpty {
                    let text = data["sender_id"] == String(UserEntity().getUserId()) ? data["ownAudio"] : data["transAudio"]
                    
                    if !(text?.isEmpty)! && text != nil {
                        self?.finishReceivingMessage()
                        if let message = JSQMessage(senderId: id, displayName: name, text: text)
                        {
                            self?.messages.append(message)
                            
                            self?.finishReceivingMessage()
                        }
                    }
                } else {
                    let text = data["sender_id"] == String(UserEntity().getUserId()) ? data["ownText"] : data["transText"]
    
                    if !(text?.isEmpty)! && text != nil {
                        if let message = JSQMessage(senderId: id, displayName: name, text: text)
                        {
                            self?.messages.append(message)
                            
                            self?.finishReceivingMessage()
                        }
                    }
                }
            }
        })
    }
    
    private func initCall() {
        let query = Constants.refs.databaseRoot.child(self.conversationName + "notification").queryLimited(toLast: 10)
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            if let data = snapshot.value as? [String: String] {
                let id = data["sender_id"]
                let senderName = data["name"]
                let video = data["videoCall"]
                
                if id != String(UserEntity().getUserId()) {
                    if video != nil && !(video?.isEmpty)! {
                        let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "Shiftgram"))
                        provider.setDelegate(self, queue: nil)
                        let update = CXCallUpdate()
                        update.remoteHandle = CXHandle(type: .generic, value: senderName!)
                        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
                    }
                }
            }
        })
    }
    
    @objc private func longPressedButton(tapGestureRecognizer: UILongPressGestureRecognizer) {
        if tapGestureRecognizer.state == .began {
            self.startRecording()
            self.addViewRecording()
            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
        }
        if tapGestureRecognizer.state == .ended {
            if audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
                self.deleteViewRecording()
                if !self.speechText.isEmpty {
                    let ref = Constants.refs.databaseRoot.child(self.conversationName).childByAutoId()
                    let params = ROGoogleTranslateParams(source: language,
                                                         target: self.friendLanguage,
                                                         text:   speechText)
                    let translator = ROGoogleTranslate()
                    translator.apiKey = "AIzaSyBePVek0atgmg3pzKQyN4oo6a7Oggog3sQ"
                    translator.translate(params: params) { (value) in
                        let message = ["sender_id": self.senderId!, "name": self.senderDisplayName, "audio": self.speechText, "ownAudio": self.speechText,
                                       "transAudio": value] as [String : Any]
                        
                        ref.setValue(message)
                        self.speechText = ""
                    }
                    
                    self.finishSendingMessage()
                }
                self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
            }
        }
    }
    
    @objc private func pressCallButton() {
        let choiceCallType = UIAlertController(title: "Choice type of calling", message: nil, preferredStyle: .actionSheet)
        
        let videoCall = UIAlertAction(title: "Video", style: .default) { (_) in
            let ref = Constants.refs.databaseRoot.child(self.conversationName + "notification").childByAutoId()
            let message = ["sender_id": self.senderId!, "name": self.senderDisplayName, "videoCall": "true"] as [String : Any]
            ref.setValue(message)
            self.performSegue(withIdentifier: "Video", sender: self)
        }
        let voiceCall = UIAlertAction(title: "Voice", style: .default) { (_) in
            let ref = Constants.refs.databaseRoot.child(self.conversationName + "notification").childByAutoId()
            let message = ["sender_id": self.senderId!, "name": self.senderDisplayName, "audioCall": "true"] as [String : Any]
            ref.setValue(message)
        }
        
        choiceCallType.addAction(videoCall)
        choiceCallType.addAction(voiceCall)
        self.present(choiceCallType, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let language = self.friendLanguage
        let conversation = self.conversationName
        if segue.identifier == "Video" {
            let videoViewController = VideoViewController()
            videoViewController.conversationName = conversation
            videoViewController.friendLaguage = language
        }
    }
    
    private func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
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
    
    private func addViewRecording() {
        let recordingView = UIView(frame: CGRect(x: 0, y: 0, width: self.inputToolbar.contentView.frame.size.width, height: self.inputToolbar.contentView.frame.size.height))
        recordingView.backgroundColor = UIColor.white
        recordingView.tag = Int(userId)
        
        let labelTimer = UILabel(frame: CGRect(x: self.inputToolbar.contentView.frame.size.width / 2.0, y: 0, width: 100, height: 44))
        labelTimer.textColor = UIColor.black
        labelTimer.text = String(format: "%02i:%02i", 0, 0)
        
        let labelText = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        labelText.textColor = UIColor.lightGray
        labelText.font = UIFont.systemFont(ofSize: 12)
        labelText.text = "Slide to cancel"
        
        let point = UIBezierPath(arcCenter: CGPoint(x: self.inputToolbar.contentView.frame.size.width / 2.0 - 10.0, y: self.inputToolbar.contentView.frame.size.height / 2.0), radius: 3, startAngle: CGFloat(0), endAngle: CGFloat(3.14 * Float(2)), clockwise: true)
        let circle = CAShapeLayer()
        circle.path = point.cgPath
        circle.fillColor = UIColor.red.cgColor
        
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
            labelTimer.text = String(format: "%02i:%02i", minute, seconds)
        })
        recordingView.addSubview(labelText)
        recordingView.addSubview(labelTimer)
        recordingView.layer.addSublayer(circle)
        self.inputToolbar.contentView.addSubview(recordingView)
    }
    
    private func deleteViewRecording() {
        self.timer.invalidate()
        let del = self.inputToolbar.contentView.viewWithTag(Int(userId))
        del?.removeFromSuperview()
    }
}

extension ChatViewController {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputToolbar.contentView.leftBarButtonItem = nil
        inputToolbar?.contentView?.rightBarButtonItem = self.rightBarButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "call"), style: .plain, target: self, action: #selector (pressCallButton))
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.initChat()
        self.initCall()
        speechRecognizer!.delegate = self
        SFSpeechRecognizer.requestAuthorization { (_) in}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != nil && text != "" {
            let ref = Constants.refs.databaseRoot.child(self.conversationName).childByAutoId()
            
            let params = ROGoogleTranslateParams(source: language,
                                                 target: self.friendLanguage,
                                                 text:   text)
            let translator = ROGoogleTranslate()
            translator.apiKey = "AIzaSyBePVek0atgmg3pzKQyN4oo6a7Oggog3sQ"
            translator.translate(params: params) { (value) in
                let message = ["sender_id": senderId, "name": senderDisplayName, "text": value, "ownText": text,
                               "transText": value]
                
                ref.setValue(message)
            }
            self.finishSendingMessage()
            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
}

extension ChatViewController: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        self.performSegue(withIdentifier: "Video", sender: self)
        Constants.refs.databaseRoot.child(self.conversationName + "notification").removeValue()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        Constants.refs.databaseRoot.child(self.conversationName + "notification").removeValue()
    }
}
