import UIKit

class ConversationViewController: UIViewController {
    
    @IBOutlet weak var conversationTableView: UITableView!
    private var conversations = ConversationEntity().getConversations()
    private var conversationName: String!
    private var friendLanguage: String!
    private var friendName: String!
    private let conversationTitle = String()
    private let userViewModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.conversationTableView.delegate = self
        self.conversationTableView.dataSource = self
        self.conversationTableView.reloadData()
        let accountUpdate = AccountLanguageUpdate(id: Int(UserEntity().getUserId()), language: (Locale.preferredLanguages.first?.parseLanguage())!, updateType: "LanguageUpdate")
        self.userViewModel.updateLanguage(accountUpdate: accountUpdate) { (_) in
            self.userViewModel.updateLanguageFriend(completion: {
                
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnsyncPressed(_ sender: Any) {
        self.conversations = ConversationEntity().getConversations()
        self.conversationTableView.reloadData()
        let alert = UIAlertController(title: "Сообщение", message: "Беседы были обновлены", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Chat" {
            let chatViewController = segue.destination as! ChatViewController
            chatViewController.conversationName = self.conversationName
            chatViewController.friendLanguage = self.friendLanguage
            chatViewController.friendName = self.friendName
            chatViewController.titleConversation = self.friendName
        }
    }
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = self.conversations[indexPath.row]
        let cell = self.conversationTableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageTableViewCell
        cell.nameLabel.text = conversation.name
        AwsHelper.downloadImage(path: conversation.photo!) { (data) in
            cell.photoImageView.image = UIImage(data: data as Data)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = self.conversations[indexPath.row]
        let userId = UserEntity().getUserId()
        self.conversationName = String(conversation.accountBId * userId)
        self.friendLanguage = FriendEntity().getFriendLanguage(id: Int(conversation.accountBId))
        self.friendName = conversation.name
        let accountUpdate = AccountLanguageUpdate(id: Int(UserEntity().getUserId()), language: (Locale.preferredLanguages.first?.parseLanguage())!, updateType: "LanguageUpdate")
        self.userViewModel.updateLanguage(accountUpdate: accountUpdate) { (_) in
            self.userViewModel.updateLanguageFriend(completion: {
            })
        }
        self.performSegue(withIdentifier: "Chat", sender: self)
    }
}

