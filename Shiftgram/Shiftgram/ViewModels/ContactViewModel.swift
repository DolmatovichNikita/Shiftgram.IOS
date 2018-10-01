import Foundation

class ContactViewModel {
    
    private let contactDataManager = ContactDataManager()
    var contacts: [Contact]!
    
    public func getContacts(completion: @escaping () -> Void){
    }
}
