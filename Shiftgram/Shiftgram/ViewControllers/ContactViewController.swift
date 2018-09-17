import UIKit
import Contacts

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var contacttableView: UITableView!
    private let contactViewModel = ContactViewModel()
    private var contacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contacttableView.delegate = self
        self.contacttableView.dataSource = self
        self.contactViewModel.getContacts {
            self.contacts = Array(self.contactViewModel.contacts)
            self.contacttableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ContactCell")
        let contact = contacts[indexPath.row]
        cell.textLabel?.text = contact.firstName
        cell.detailTextLabel?.text = contact.phone
        
        return cell
    }
}
