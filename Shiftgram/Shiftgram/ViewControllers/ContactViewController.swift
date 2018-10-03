import UIKit
import Contacts

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var contacttableView: UITableView!
    private let contactViewModel = ContactViewModel()
    private let friendViewModel = FriendViewModel()
    private var activityIndicator: ActivityIndicator!
    private var friends = [FriendModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contacttableView.delegate = self
        self.contacttableView.dataSource = self
        self.activityIndicator = ActivityIndicator(view: self.view)
        self.friends = FriendEntity().getFriends()
        self.contacttableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        let conversationViewController = ChatViewController()
        self.present(conversationViewController, animated: true, completion: nil)
    }
}
