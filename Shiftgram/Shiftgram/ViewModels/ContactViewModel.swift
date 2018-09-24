import Foundation

class ContactViewModel {
    
    private let contactDataManager = ContactDataManager()
    var contacts: [Contact]!
    
    
    public func getContacts(completion: @escaping () -> Void){
        self.contactDataManager.getContacts {response in
            self.contacts = response
            completion()
        }
    }
}
