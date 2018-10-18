import UIKit
import Contacts
import CallKit

class ContactViewController: UIViewController {
    
    @IBOutlet weak var contacttableView: UITableView!
    private let contactViewModel = ContactViewModel()
    private let friendViewModel = FriendViewModel()
    private var activityIndicator: ActivityIndicator!
    private var friends = [FriendModel]()
    private let conversations = ConversationEntity().getConversations()
    private let userId = UserEntity().getUserId()
    private var currentConversationName = String()
    private var currentFriendLanguage = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAudioSession()
        self.initConversations()
        self.contacttableView.delegate = self
        self.contacttableView.dataSource = self
        self.activityIndicator = ActivityIndicator(view: self.view)
        self.friends = FriendEntity().getFriends()
        self.contacttableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Video" {
            let videoViewController = segue.destination as? VideoViewController
            videoViewController?.conversationName = self.currentConversationName
            videoViewController?.friendLaguage = self.currentFriendLanguage
            Constants.refs.databaseRoot.child(self.currentConversationName + "notification").removeValue()
            self.currentConversationName = ""
            self.currentFriendLanguage = ""
        }
    }
    
    @IBAction func btnSyncPressed(_ sender: Any) {
        UserEntity().updateUser(value: true, key: "isSync")
        self.activityIndicator.startLoading()
        self.contactViewModel.syncContacts {values in
            self.friends = values
            self.activityIndicator.stopLoading()
            self.contacttableView.reloadData()
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

extension ContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friend = self.friends[indexPath.row]
        let cell = self.contacttableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactTableViewCell
        cell.nameLabel.text = friend.username
        AwsHelper.downloadImage(path: friend.photo) { (data) in
            cell.contactImageView.image = UIImage(data: data as Data)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = self.friends[indexPath.row]
        if !self.contactViewModel.isAddNewConversation(accountBId: friend.id) {
            ConversationEntity().addConversation(friendModel: friend)
        }
        let chatViewController = ChatViewController()
        let userId = UserEntity().getUserId()
        chatViewController.conversationName = String(friend.id * Int(userId))
        chatViewController.friendLanguage = FriendEntity().getFriendLanguage(id: friend.id)
        self.present(chatViewController, animated: true, completion: nil)
    }
}

extension ContactViewController: CXProviderDelegate {
    
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        self.performSegue(withIdentifier: "Video", sender: self)
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }
}
