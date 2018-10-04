import UIKit

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var conversationTableView: UITableView!
    private var conversations = [Conversation]()
    private var conversationName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.conversationTableView.delegate = self
        self.conversationTableView.dataSource = self
        self.conversations = ConversationEntity().getConversations()
        self.conversationTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
        self.performSegue(withIdentifier: "Chat", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Chat" {
            var chatViewController = segue.destination as! ChatViewController
            chatViewController.conversationName = self.conversationName
        }
    }
}
