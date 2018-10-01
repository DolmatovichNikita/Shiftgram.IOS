import Foundation

class ContactViewModel {
    
    private let contactDataManager = ContactDataManager()
    private let friendDataManager = FriendDataManager()
    private let friendEntity = FriendEntity()
    
    public func syncContacts(completion: @escaping ([FriendModel]) -> Void) {
        self.addNewContacts()
        self.friendDataManager.fetchFriends {
            let friends = self.friendEntity.getFriends()
                
            completion(friends)
        }
    }
    
    private func addNewContacts() {
        let isSync = UserEntity().isSync()
        let countFriend = FriendEntity().getFriends().count
        
        if isSync && countFriend > 0 {
            self.addContactsIfSync()
        } else {
            self.addContactsIfNotSync()
        }
    }
    
    private func addContactsIfNotSync() {
        let userId = UserEntity().getUserId()
        let contacts = self.getAllContacts()
        
        for contact in contacts {
            let accountFriendModel = AccountFriendModel(accountAId: Int(userId), accountBPhone: contact.phone)
                
            self.friendDataManager.addFriend(accountFriendModel: accountFriendModel, completion: { (_) in })
        }
    }
    
    private func addContactsIfSync() {
        let userId = UserEntity().getUserId()
        let contacts = self.getFilteredContacts()
        
        for contact in contacts {
            let accountFriendModel = AccountFriendModel(accountAId: Int(userId), accountBPhone: contact.phone)
                
            self.friendDataManager.addFriend(accountFriendModel: accountFriendModel, completion: { (_) in })
        }
    }
    
    private func getAllContacts() -> [Contact] {
        return self.contactDataManager.getContacts()
    }
    
    private func getFilteredContacts() -> [Contact] {
        let friends = self.friendEntity.getFriends()
        var filteredContracts = [Contact]()
        let contacts = self.contactDataManager.getContacts()
        
        for friend in friends {
            for contact in contacts {
                if friend.phone != contact.phone {
                    let contact = Contact(firstName: contact.firstName, phone: contact.phone)
                    filteredContracts.append(contact)
                }
            }
        }
        
        return filteredContracts
    }
}
