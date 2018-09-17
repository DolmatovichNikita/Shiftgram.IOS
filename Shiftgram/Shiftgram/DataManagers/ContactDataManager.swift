import Foundation
import Contacts

class ContactDataManager {
    private let contactStore = CNContactStore()
    
    public func getContacts(completion: @escaping ([Contact]) -> Void){
        var contacts = [Contact]()
        let key = [CNContactGivenNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: key)
        
        do {
            try self.contactStore.enumerateContacts(with: request) { (value, stoppingPointer)  in
                let contact = Contact(firstName: value.givenName, phone: (value.phoneNumbers.first?.value.stringValue)!)
                contacts.append(contact)
                completion(contacts)
            }
        } catch {
            print("Failed")
        }
    }
}
