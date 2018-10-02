import Foundation
import CoreData

class ConversationEntity {
    
    private let appDelegate: AppDelegate!
    private let context: NSManagedObjectContext
    
    init() {
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.context = self.appDelegate.persistentContainer.viewContext
    }
    
    public func addConversation(friendModel: FriendModel) {
        let entity = NSEntityDescription.entity(forEntityName: "Conversation", in: self.context)
        let conversation = NSManagedObject(entity: entity!, insertInto: self.context)
        conversation.setValue(friendModel.username, forKey: "name")
        conversation.setValue(friendModel.photo, forKey: "photo")
        conversation.setValue(friendModel.id, forKey: "accountBId")
        
        do {
            try self.context.save()
        } catch {
            print("Failed")
        }
    }
}
