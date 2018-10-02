import UIKit

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var conversationTableView: UITableView!
    private var conversations = [Conversation]()
    
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
        let cell = self.conversationTableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageTableViewCell
        cell.nameLabel.text = conversations[indexPath.row].name
        
        return cell
    }
}
