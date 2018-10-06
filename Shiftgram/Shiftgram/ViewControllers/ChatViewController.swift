import UIKit
import JSQMessagesViewController
import ROGoogleTranslate
import AVFoundation
import Speech

class ChatViewController: JSQMessagesViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, SFSpeechRecognizerDelegate {

    public var conversationName = String()
    public var friendLanguage = String()
    private var messages = [JSQMessage]()
    private let userId = UserEntity().getUserId()
    private var language = (Locale.preferredLanguages.first?.parseLanguage())!
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
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
    
    lazy var leftBarButtonItem: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "microphone"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        let gestureRecgnizer = UILongPressGestureRecognizer(target: self, action: #selector (longPressedButton(tapGestureRecognizer:)))
        button.addGestureRecognizer(gestureRecgnizer)
        return button
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputToolbar.contentView.leftBarButtonItem = self.leftBarButtonItem
        //inputToolbar?.contentView?.rightBarButtonItem = self.rightBarButtonItem
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.initChat()
        self.initAudio()
        speechRecognizer!.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (_) in}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
    }
    
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
                        if let message = JSQMessage(senderId: id, displayName: name, text: text)
                        {
                            self?.messages.append(message)
                            
                            self?.finishReceivingMessage()
                        }
                    }
                    /*AwsHelper.downloadRecord(path: audioUrl!, completion: { (data) in
                        let audioItem = JSQAudioMediaItem(data: data as Data)
                        let message = JSQMessage(senderId: self!.senderId, displayName: self!.senderDisplayName, media: audioItem)
                        self!.messages.append(message!)
                        self?.finishReceivingMessage()
                    })*/
                    
                } else {
                    let text = data["sender_id"] == self!.senderId ? data["ownText"] : data["transText"]
                    
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
    
    private func initAudio() {
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let soundFileURL = dirPaths[0].appendingPathComponent("sound.caf")
        let recordSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0] as [String : Any]
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(
                AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL,
                                                settings: recordSettings as [String : AnyObject])
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    @objc private func longPressedButton(tapGestureRecognizer: UILongPressGestureRecognizer) {
        if tapGestureRecognizer.state == .began {
            //self.initAudio()
            //audioRecorder?.record()
            self.startRecording()
            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
        }
        if tapGestureRecognizer.state == .ended {
            if audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
                let ref = Constants.refs.databaseRoot.child(self.conversationName).childByAutoId()
                let params = ROGoogleTranslateParams(source: language,
                                                     target: self.friendLanguage,
                                                     text:   speechText)
                let translator = ROGoogleTranslate()
                translator.apiKey = "AIzaSyBePVek0atgmg3pzKQyN4oo6a7Oggog3sQ"
                DispatchQueue.main.async {
                    translator.translate(params: params) { (value) in
                        let message = ["sender_id": self.senderId!, "name": self.senderDisplayName, "audio": self.speechText, "ownAudio": self.speechText,
                                       "transAudio": value] as [String : Any]
                        
                        ref.setValue(message)
                    }
                }
                let uttr = AVSpeechUtterance(string: self.speechText)
                uttr.voice = AVSpeechSynthesisVoice(language: "en-US")
                uttr.rate = 0.5
                AVSpeechSynthesizer().speak(uttr)
                
                self.finishSendingMessage()
                self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
            }
            /*audioRecorder?.stop()

            AwsHelper.uploadRecord(audioRecord: self.audioRecorder!) { (value) in
                let ref = Constants.refs.databaseRoot.child(self.conversationName).childByAutoId()
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                let message = ["sender_id": self.senderId!, "name": self.senderDisplayName, "audioUrl": value] as [String : Any]
                ref.setValue(message)
                self.finishSendingMessage()
                self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
            }*/
            
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.speechText = (result?.bestTranscription.formattedString)!  //9
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
}

extension ChatViewController {
    
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
