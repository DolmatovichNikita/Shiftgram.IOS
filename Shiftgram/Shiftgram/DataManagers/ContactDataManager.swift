import Foundation
import Contacts

class ContactDataManager {
    let contactStore = CNContactStore()
    
    public func getContacts() -> [Contact] {
        var contacts = [Contact]()
        let key = [CNContactGivenNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: key)
        
        do {
            try self.contactStore.enumerateContacts(with: request) { (value, stoppingPointer)  in
                let contact = Contact(firstName: value.givenName, lastName: value.middleName, phone: (value.phoneNumbers.first?.value.stringValue)!)
                contacts.append(contact)
            }
        } catch {
            print("Failed")
        }
        
        return contacts
    }
}
