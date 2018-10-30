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
            let alert = UIAlertController(title: "Сообщение", message: "Контакты были обновлены", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
        self.performSegue(withIdentifier: "ContactToChat", sender: self)
    }
}

