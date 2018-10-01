import Foundation
import Contacts

class ContactDataManager {
    
    private let contactStore = CNContactStore()
    
    public func getContacts() -> [Contact] {
        var filteredContacts = [Contact]()
        let key = [CNContactGivenNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: key)
        
        do {
            var contacts = [Contact]()
            
            try self.contactStore.enumerateContacts(with: request) { (value, stoppingPointer)  in
                let phone = (value.phoneNumbers.first?.value.stringValue)!.parseCNPhone()
                let contact = Contact(firstName: value.givenName, phone: phone)
                contacts.append(contact)
            }
            let userEntity = UserEntity()
            filteredContacts = contacts.filter({ (value) -> Bool in
                value.phone != userEntity.getUserPhone()
            })
        } catch {
            print("Failed")
        }
        
        return filteredContacts
    }
}
