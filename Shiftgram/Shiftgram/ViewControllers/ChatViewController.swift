import UIKit
import JSQMessagesViewController
import ROGoogleTranslate
import AVFoundation
import Speech
import CallKit
import MobileCoreServices

class ChatViewController: JSQMessagesViewController, AVAudioRecorderDelegate, SFSpeechRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public var titleConversation = String()
    public var conversationName = String()
    public var friendName = String()
    public var friendLanguage = String()
    private var messages = [JSQMessage]()
    private let userId = UserEntity().getUserId()
    private var language = (Locale.preferredLanguages.first?.parseLanguage())!
    private let userViewModel = UserViewModel()
    
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
    
    lazy var leftBarButtonItem: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "camera"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        let gestureRecgnizer = UITapGestureRecognizer(target: self, action: #selector (imagePressed(tapGestureRecognizer:)))
        button.addGestureRecognizer(gestureRecgnizer)
        return button
    }()
    
    @objc private func imagePressed(tapGestureRecognizer: UITapGestureRecognizer) {
        let choiceImageAlert = UIAlertController(title: "Select image from", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let cameraRollAction = UIAlertAction(title: "Camera Roll", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        choiceImageAlert.addAction(cameraAction)
        choiceImageAlert.addAction(cameraRollAction)
        self.present(choiceImageAlert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            AwsHelper.uploadImage(image: image) { (value) in
                let ref = Constants.refs.databaseRoot.child(self.conversationName).childByAutoId()
                
                let message = ["sender_id": String(UserEntity().getUserId()), "name": self.senderDisplayName, "photo": value] as [String : Any]
                
                ref.setValue(message)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func initChat() {
        senderId = String(userId)
        senderDisplayName = String(userId)
        title = "Chat: \(self.friendName)"
        
        let query = Constants.refs.databaseRoot.child(self.conversationName).queryLimited(toLast: 10)
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            if let data = snapshot.value as? [String: String] {
                let id = data["sender_id"]
                let name = data["name"]
                let audioUrl = data["audio"]
                let photo = data["photo"]
                let text = data["sender_id"] == String(UserEntity().getUserId()) ? data["ownText"] : data["transText"]
                if photo != nil && !(photo?.isEmpty)! {
                    AwsHelper.downloadImage(path: photo!, completion: { (data) in
                        let image = UIImage(data: data as Data)
                        let ph = JSQPhotoMediaItem(image: image!)
                        let message = JSQMessage(senderId: id, displayName: name, media: ph)
                        self?.messages.append(message!)
                        self?.finishReceivingMessage()
                    })
                }
                else if audioUrl != nil &&  !audioUrl!.isEmpty {
                    let text = data["sender_id"] == String(UserEntity().getUserId()) ? data["ownAudio"] : data["transAudio"]
                    
                    if !(text?.isEmpty)! && text != nil {
                        self?.finishReceivingMessage()
                        if let message = JSQMessage(senderId: id, displayName: name, text: text)
                        {
                            self?.messages.append(message)
                            
                            self?.finishReceivingMessage()
                        }
                    }
                }
                else if !(text?.isEmpty)! && text != nil{
                    
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
                    let userDM = UserDataManager()
                    let frId = (Int(self.conversationName)! / Int(self.userId))
                    userDM.getFriendLanguage(id: frId) { (value) in
                        let ref = Constants.refs.databaseRoot.child(self.conversationName).childByAutoId()
                        if self.language == value {
                            let message = ["sender_id": self.senderId!, "name": self.senderDisplayName, "audio": self.speechText, "ownAudio": self.speechText,
                                           "transAudio": self.speechText] as [String : Any]
                            
                            ref.setValue(message)
                            self.speechText = ""
                            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
                        } else {
                            let params = ROGoogleTranslateParams(source: self.language,
                                                                 target: value,
                                                                 text:   self.speechText)
                            let translator = ROGoogleTranslate()
                            translator.apiKey = "AIzaSyA03pGAne7Bz9t8Y-ZeW0K-TVM15vEZYLQ"
                            translator.translate(params: params) { (value) in
                                let message = ["sender_id": self.senderId!, "name": self.senderDisplayName, "audio": self.speechText, "ownAudio": self.speechText,
                                               "transAudio": value] as [String : Any]
                                
                                ref.setValue(message)
                                self.speechText = ""
                            }
                            
                            self.finishSendingMessage()
                            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
                        }
                    }
                }
                self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
            }
        }
    }
    
    @objc private func pressCallButton() {
        let choiceCallType = UIAlertController(title: "Choice type of calling", message: nil, preferredStyle: .actionSheet)
        
        let videoCall = UIAlertAction(title: "Video", style: .default) { (_) in
            let ref = Constants.refs.databaseRoot.child(self.conversationName + "notification").childByAutoId()
            let message = ["sender_id": self.senderId!, "name": self.titleConversation, "videoCall": "true"] as [String : Any]
            ref.setValue(message)
            self.performSegue(withIdentifier: "VideoChat", sender: self)
        }
        let voiceCall = UIAlertAction(title: "Voice", style: .default) { (_) in
            let ref = Constants.refs.databaseRoot.child(self.conversationName + "notification").childByAutoId()
            let message = ["sender_id": self.senderId!, "name": self.titleConversation, "audioCall": "true"] as [String : Any]
            ref.setValue(message)
            let audioViewController = AudioViewController()
            audioViewController.name = self.friendName
            audioViewController.conversationName = self.conversationName
            audioViewController.friendLanguage = self.friendLanguage
            self.navigationController?.pushViewController(audioViewController, animated: true)
        }
        
        choiceCallType.addAction(videoCall)
        choiceCallType.addAction(voiceCall)
        self.present(choiceCallType, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let language = self.friendLanguage
        let conversation = self.conversationName
        if segue.identifier == "VideoChat" {
            let videoViewController = segue.destination as! VideoViewController
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
        inputToolbar.contentView.leftBarButtonItem = self.leftBarButtonItem
        inputToolbar?.contentView?.rightBarButtonItem = self.rightBarButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "call"), style: .plain, target: self, action: #selector (pressCallButton))
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.initChat()
        speechRecognizer!.delegate = self
        SFSpeechRecognizer.requestAuthorization { (_) in}
        let accountUpdate = AccountLanguageUpdate(id: Int(UserEntity().getUserId()), language: (Locale.preferredLanguages.first?.parseLanguage())!, updateType: "LanguageUpdate")
        self.userViewModel.updateLanguage(accountUpdate: accountUpdate) { (_) in
            self.userViewModel.updateLanguageFriend(completion: {
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != nil && text != "" {
            let userDM = UserDataManager()
            let frId = (Int(self.conversationName)! / Int(self.userId))
            userDM.getFriendLanguage(id: frId) { (value) in
                let ref = Constants.refs.databaseRoot.child(self.conversationName).childByAutoId()
                print(self.language + " " + value)
                if self.language == value {
                    let message = ["sender_id": senderId, "name": senderDisplayName, "text": text, "ownText": text,
                                   "transText": text]
                    
                    ref.setValue(message)
                    self.finishSendingMessage()
                } else {
                    let params = ROGoogleTranslateParams(source: self.language,
                                                         target: value,
                                                         text:   text)
                    let translator = ROGoogleTranslate()
                    translator.apiKey = "AIzaSyA03pGAne7Bz9t8Y-ZeW0K-TVM15vEZYLQ"
                    translator.translate(params: params) { (value) in
                        let message = ["sender_id": senderId, "name": senderDisplayName, "text": value, "ownText": text,
                                       "transText": value]
                        
                        ref.setValue(message)
                    }
                    self.finishSendingMessage()
                    self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
                }
            }
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


