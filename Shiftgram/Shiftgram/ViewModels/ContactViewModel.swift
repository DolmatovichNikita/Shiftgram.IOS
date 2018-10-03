import Foundation

class ContactViewModel {
    
    private let contactDataManager = ContactDataManager()
    private let friendDataManager = FriendDataManager()
    private let friendEntity = FriendEntity()
    private let conversationEntity = ConversationEntity()
    
    public func syncContacts(completion: @escaping ([FriendModel]) -> Void) {
        self.addContacts()
        self.friendDataManager.fetchFriends {
            let friends = self.friendEntity.getFriends()
                
            completion(friends)
        }
    }
    
    public func isAddNewConversation(accountBId: Int) -> Bool {
        return conversationEntity.isExistConversation(accountBId: accountBId)
    }
    
    private func addContacts() {
        let userId = UserEntity().getUserId()
        let contacts = self.getAllContacts()
        
        for contact in contacts {
            let accountFriendModel = AccountFriendModel(accountAId: Int(userId), accountBPhone: contact.phone)
                
            self.friendDataManager.addFriend(accountFriendModel: accountFriendModel, completion: { (_) in })
        }
    }
    
    private func getAllContacts() -> [Contact] {
        return self.contactDataManager.getContacts()
    }
}
