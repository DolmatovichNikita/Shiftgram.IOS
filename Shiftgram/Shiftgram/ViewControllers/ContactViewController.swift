import UIKit
import Contacts

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var contacttableView: UITableView!
    private let contactViewModel = ContactViewModel()
    private let friendViewModel = FriendViewModel()
    private var contacts = [Contact]()
    private var activityIndicator: ActivityIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contacttableView.delegate = self
        self.contacttableView.dataSource = self
        self.activityIndicator = ActivityIndicator(view: self.view)
        self.contactViewModel.getContacts {
            self.contacts = Array(self.contactViewModel.contacts)
            self.contacttableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnSyncPressed(_ sender: Any) {
        self.activityIndicator.startLoading()
        let id = UserEntity().getUserId()
        for contact in contacts {
            let accountFriendModel = AccountFriendModel(accountAId: Int(id), accountBPhone: contact.phone)
            self.friendViewModel.syncFriends(accountFriendModel: accountFriendModel) {}
        }
        self.activityIndicator.stopLoading()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.contacttableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactTableViewCell
        let contact = contacts[indexPath.row]
        cell.nameLabel.text = contact.firstName
        
        return cell
    }
}
