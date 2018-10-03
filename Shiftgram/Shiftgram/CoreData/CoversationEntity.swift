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
    
    public func getConversations() -> [Conversation] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversation")
        var conversations = [Conversation]()
        
        do {
            conversations = try self.context.fetch(request) as! [Conversation]
        } catch {
            print("Failed")
        }
        
        return conversations
    }
    
    public func deleteAllConversations() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversation")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try self.context.execute(deleteRequest)
            try self.context.save()
        } catch {
            print("Failed")
        }
    }
    
    public func isExistConversation(accountBId: Int) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversation")
        var isExist = false
        
        request.predicate = NSPredicate(format: "accountBId == %@", String(accountBId))
        do {
            let conversation = try self.context.fetch(request) as! [Conversation]
            if conversation.count > 0 {
                isExist = true
            }
        } catch {
            print("Failed")
        }
        
        return isExist
    }
}
