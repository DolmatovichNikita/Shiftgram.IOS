import UIKit
import TwilioVideo
import Speech
import Firebase
import AVFoundation
import ROGoogleTranslate

class VideoViewController: UIViewController{

    public var conversationName = String()
    public var friendLaguage = String()
    public var from = String()
    private var language = (Locale.preferredLanguages.first?.parseLanguage())!
    private var accessToken: String?
    private let videoAccessViewModel = VideoAccessViewModel()
    private let roomName = "Shiftgram"
    private let userId = String(UserEntity().getUserId())
    private var indicator: ActivityIndicator?
    
    private var room: TVIRoom?
    private var camera: TVICameraCapturer?
    private var localVideoTrack: TVILocalVideoTrack?
    private var localAudioTrack: TVILocalAudioTrack?
    private var remoteParticipant: TVIRemoteParticipant?
    private var remoteView: TVIVideoView!
    
    @IBOutlet weak var previewView: TVIVideoView!
    @IBOutlet weak var recordingImageView: UIImageView!
    @IBOutlet weak var disconnectImageView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: Locale.preferredLanguages.first!))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var speechText = ""
    private let synthezier = AVSpeechSynthesizer()
    private let audioSession = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicator = ActivityIndicator(view: self.view)
        self.indicator!.startLoading()
        let disconnectGesture = UITapGestureRecognizer(target: self, action: #selector (tapGestureDisconnect(gesture:)))
        self.disconnectImageView.isUserInteractionEnabled = true
        self.disconnectImageView.addGestureRecognizer(disconnectGesture)
        let recordingGesture = UITapGestureRecognizer(target: self, action: #selector (tapGestureRecroding(gesture:)))
        self.recordingImageView.isUserInteractionEnabled = true
        self.recordingImageView.addGestureRecognizer(recordingGesture)
        self.initChat()
        self.startPreview()
        self.initConnection()
        self.initAudioSession()
        SFSpeechRecognizer.requestAuthorization { (_) in}
    }
    
    @objc private func tapGestureDisconnect(gesture: UITapGestureRecognizer) {
        Constants.refs.databaseRoot.child(self.conversationName + "video").removeValue()
        self.room!.disconnect()
    }
    
    @objc private func tapGestureRecroding(gesture: UITapGestureRecognizer) {
        let user = self.userId
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            let ref = Constants.refs.databaseRoot.child(self.conversationName + "video").childByAutoId()
            
            let params = ROGoogleTranslateParams(source: self.language,
                                                 target: self.friendLaguage,
                                                 text:   self.speechText)
            let translator = ROGoogleTranslate()
            translator.apiKey = "AIzaSyA03pGAne7Bz9t8Y-ZeW0K-TVM15vEZYLQ"
            translator.translate(params: params) { (value) in
                let message = ["sender_id": user, "ownText": self.speechText, "transText": value]
                
                ref.setValue(message)
                self.speechText = ""
            }
            self.recordingImageView.image = UIImage(named: "recording")
            self.recordingImageView.contentMode = .scaleAspectFit
        } else {
            self.startRecording()
            self.recordingImageView.image = UIImage(named: "inRecording")
            self.recordingImageView.contentMode = .scaleAspectFit
        }
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
        let query = Constants.refs.databaseRoot.child(self.conversationName + "video").queryLimited(toLast: 10)
        
        _ = query.observe(.childAdded, with: { snapshot in
            if let data = snapshot.value as? [String: String] {
                let id = data["sender_id"]
                let text = id != user ? data["transText"] : nil
                if text != nil && !(text?.isEmpty)! {
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
    
    private func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
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
    
    private func initConnection() {
        let videoAccessModel = VideoAccessModel(name: String(UserEntity().getUserId()), room: self.roomName)
        self.videoAccessViewModel.getToken(videoAccessModel: videoAccessModel) { (token) in
            self.accessToken = token
            
            self.prepareLocalMedia()
            
            let connectOptions = TVIConnectOptions.init(token: self.accessToken!) { (builder) in
                
                if self.language == self.friendLaguage {
                    builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [TVILocalAudioTrack]()
                }
                builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [TVILocalVideoTrack]()
                
                if let preferredAudioCodec = Settings.shared.audioCodec {
                    builder.preferredAudioCodecs = [preferredAudioCodec]
                }
                
                if let preferredVideoCodec = Settings.shared.videoCodec {
                    builder.preferredVideoCodecs = [preferredVideoCodec]
                }
                
                if let encodingParameters = Settings.shared.getEncodingParameters() {
                    builder.encodingParameters = encodingParameters
                }
                
                builder.roomName = self.roomName
            }
            
            self.room = TwilioVideo.connect(with: connectOptions, delegate: self)
        }
    }
    
    private func startPreview() {
        self.camera = TVICameraCapturer(source: .frontCamera, delegate: self)
        self.localVideoTrack = TVILocalVideoTrack.init(capturer: camera!, enabled: true, constraints: nil, name: "Camera")
        if (localVideoTrack == nil) {
            print("Failed to create video track")
        } else {
            self.localVideoTrack!.addRenderer(self.previewView)
            let tap = UITapGestureRecognizer(target: self, action: #selector(flipCamera))
            self.previewView.addGestureRecognizer(tap)
        }
    }
    
    @objc private func flipCamera() {
        if (self.camera?.source == .frontCamera) {
            self.camera?.selectSource(.backCameraWide)
        } else {
            self.camera?.selectSource(.frontCamera)
        }
    }
    
    private func setupRemoteVideoView() {
        self.remoteView = TVIVideoView.init(frame: CGRect.zero, delegate:self)
        
        self.view.insertSubview(self.remoteView!, at: 0)
        self.remoteView!.contentMode = .scaleAspectFit;
        
        let centerX = NSLayoutConstraint(item: self.remoteView!,
                                         attribute: NSLayoutAttribute.centerX,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutAttribute.centerX,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerX)
        let centerY = NSLayoutConstraint(item: self.remoteView!,
                                         attribute: NSLayoutAttribute.centerY,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutAttribute.centerY,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerY)
        let width = NSLayoutConstraint(item: self.remoteView!,
                                       attribute: NSLayoutAttribute.width,
                                       relatedBy: NSLayoutRelation.equal,
                                       toItem: self.view,
                                       attribute: NSLayoutAttribute.width,
                                       multiplier: 1,
                                       constant: 0);
        self.view.addConstraint(width)
        let height = NSLayoutConstraint(item: self.remoteView!,
                                        attribute: NSLayoutAttribute.height,
                                        relatedBy: NSLayoutRelation.equal,
                                        toItem: self.view,
                                        attribute: NSLayoutAttribute.height,
                                        multiplier: 1,
                                        constant: 0);
        self.view.addConstraint(height)
    }
    
    private func cleanupRemoteParticipant() {
        if ((self.remoteParticipant) != nil) {
            if ((self.remoteParticipant?.videoTracks.count)! > 0) {
                let remoteVideoTrack = self.remoteParticipant?.remoteVideoTracks[0].remoteTrack
                remoteVideoTrack?.removeRenderer(self.remoteView!)
                self.remoteView?.removeFromSuperview()
                self.remoteView = nil
            }
        }
        self.remoteParticipant = nil
    }
    
    private func prepareLocalMedia() {
        if (localAudioTrack == nil) {
            if language == friendLaguage {
                localAudioTrack = TVILocalAudioTrack.init(options: nil, enabled: true, name: "Microphone")
            }
            
            if (localAudioTrack == nil) {
            }
        }
        
        if (localVideoTrack == nil) {
            self.startPreview()
        }
    }
}

extension VideoViewController : TVIRoomDelegate {
    
    func didConnect(to room: TVIRoom) {
        if (room.remoteParticipants.count > 0) {
            self.remoteParticipant = room.remoteParticipants[0]
            self.remoteParticipant?.delegate = self
        }
    }
    
    func room(_ room: TVIRoom, didDisconnectWithError error: Error?) {
        self.cleanupRemoteParticipant()
        self.room = nil
    }
    
    func room(_ room: TVIRoom, didFailToConnectWithError error: Error) {
        self.room = nil
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == nil) {
            self.remoteParticipant = participant
            self.remoteParticipant?.delegate = self
        }
    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == participant) {
            cleanupRemoteParticipant()
        }
    }
}

extension VideoViewController : TVIRemoteParticipantDelegate {
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           publishedVideoTrack publication: TVIRemoteVideoTrackPublication) {
        
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           unpublishedVideoTrack publication: TVIRemoteVideoTrackPublication) {
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           publishedAudioTrack publication: TVIRemoteAudioTrackPublication) {
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           unpublishedAudioTrack publication: TVIRemoteAudioTrackPublication) {
    }
    
    func subscribed(to videoTrack: TVIRemoteVideoTrack,
                    publication: TVIRemoteVideoTrackPublication,
                    for participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == participant) {
            setupRemoteVideoView()
            videoTrack.addRenderer(self.remoteView!)
            self.indicator!.stopLoading()
            self.loadingLabel.text = ""
        }
    }
    
    func unsubscribed(from videoTrack: TVIRemoteVideoTrack,
                      publication: TVIRemoteVideoTrackPublication,
                      for participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == participant) {
            videoTrack.removeRenderer(self.remoteView!)
            self.remoteView?.removeFromSuperview()
            self.remoteView = nil
        }
    }
    
    func subscribed(to audioTrack: TVIRemoteAudioTrack,
                    publication: TVIRemoteAudioTrackPublication,
                    for participant: TVIRemoteParticipant) {
    }
    
    func unsubscribed(from audioTrack: TVIRemoteAudioTrack,
                      publication: TVIRemoteAudioTrackPublication,
                      for participant: TVIRemoteParticipant) {
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           enabledVideoTrack publication: TVIRemoteVideoTrackPublication) {
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           disabledVideoTrack publication: TVIRemoteVideoTrackPublication) {
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           enabledAudioTrack publication: TVIRemoteAudioTrackPublication) {
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           disabledAudioTrack publication: TVIRemoteAudioTrackPublication) {
    }
    
    func failedToSubscribe(toAudioTrack publication: TVIRemoteAudioTrackPublication,
                           error: Error,
                           for participant: TVIRemoteParticipant) {
    }
    
    func failedToSubscribe(toVideoTrack publication: TVIRemoteVideoTrackPublication,
                           error: Error,
                           for participant: TVIRemoteParticipant) {
    }
}

extension VideoViewController : TVIVideoViewDelegate {
    func videoView(_ view: TVIVideoView, videoDimensionsDidChange dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

extension VideoViewController : TVICameraCapturerDelegate {
    func cameraCapturer(_ capturer: TVICameraCapturer, didStartWith source: TVICameraCaptureSource) {
        self.previewView.shouldMirror = (source == .frontCamera)
    }
}
