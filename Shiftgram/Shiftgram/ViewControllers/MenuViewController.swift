import UIKit
import CallKit

class MenuViewController: UITabBarController {
    
    private let conversations = ConversationEntity().getConversations()
    private let userId = UserEntity().getUserId()
    private var currentConversationName = String()
    private var currentFriendLanguage = String()
    private var currentName = String()
    private var isAudio = String()
    private var isVideo = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAudioSession()
        self.initConversations()
        self.initAudioConversation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Video" {
            let videoViewController = segue.destination as? VideoViewController
            videoViewController?.conversationName = self.currentConversationName
            videoViewController?.friendLaguage = self.currentFriendLanguage
            Constants.refs.databaseRoot.child(self.currentConversationName + "notification").removeValue()
            self.currentConversationName = ""
            self.currentFriendLanguage = ""
            self.isVideo = ""
            self.isAudio = ""
        }
    }
    
    private func initAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    private func initConversations() {
        for conversation in conversations {
            let conversationName = String(userId * conversation.accountBId)
            let query = Constants.refs.databaseRoot.child(conversationName + "notification").queryLimited(toLast: 10)
            
            _ = query.observe(.childAdded, with: { snapshot in
                if let data = snapshot.value as? [String: String] {
                    let id = data["sender_id"]
                    let name = data["name"]
                    let video = data["videoCall"]
                    
                    if id != String(self.userId) {
                        if video != nil && !(video?.isEmpty)! {
                            self.currentConversationName = conversationName
                            self.currentFriendLanguage = FriendEntity().getFriendLanguage(id: Int(conversation.accountBId))
                            self.isVideo = "video"
                            self.incomingCall(senderName: name!)
                        }
                    }
                }
            })
        }
    }
    
    private func initAudioConversation() {
        for conversation in conversations {
            let conversationName = String(userId * conversation.accountBId)
            let query = Constants.refs.databaseRoot.child(conversationName + "notification").queryLimited(toLast: 10)
            
            _ = query.observe(.childAdded, with: { snapshot in
                if let data = snapshot.value as? [String: String] {
                    let id = data["sender_id"]
                    let name = data["name"]
                    let video = data["audioCall"]
                    
                    if id != String(self.userId) {
                        if video != nil && !(video?.isEmpty)! {
                            self.currentConversationName = conversationName
                            self.currentFriendLanguage = FriendEntity().getFriendLanguage(id: Int(conversation.accountBId))
                            self.currentName = conversation.name!
                            self.isAudio = "audio"
                            self.incomingCall(senderName: name!)
                        }
                    }
                }
            })
        }
    }
    
    private func incomingCall(senderName: String) {
        let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "Shiftgram"))
        provider.setDelegate(self, queue: nil)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: senderName)
        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
    }
}

extension MenuViewController: CXProviderDelegate {
    
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        if !self.isVideo.isEmpty {
            self.performSegue(withIdentifier: "Video", sender: self)
        } else if !self.isAudio.isEmpty {
            let audioViewController = AudioViewController()
            audioViewController.name = self.currentName
            audioViewController.conversationName = self.currentConversationName
            audioViewController.friendLanguage = self.currentFriendLanguage
            let ref = Constants.refs.databaseRoot.child(self.currentConversationName + "audioCalling").childByAutoId()
            let message = ["sender_id": String(self.userId)]
            ref.setValue(message)
            self.currentFriendLanguage = ""
            self.isVideo = ""
            self.isAudio = ""
            Constants.refs.databaseRoot.child(self.currentConversationName + "notification").removeValue()
            self.currentConversationName = ""
            self.present(audioViewController, animated: true, completion: nil)
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }
}


