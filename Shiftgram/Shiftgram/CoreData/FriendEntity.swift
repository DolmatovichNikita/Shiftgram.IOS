import Foundation
import CoreData
import UIKit

class FriendEntity {
    
    private let appDelegate:AppDelegate!
    private let context: NSManagedObjectContext!
    
    init() {
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.context = self.appDelegate.persistentContainer.viewContext
    }
    
    public func addFriend(friendModel: FriendModel) {
        let entity = NSEntityDescription.entity(forEntityName: "Friend", in: self.context)
        let friend = NSManagedObject(entity: entity!, insertInto: self.context)
        friend.setValue(friendModel.id, forKey: "id")
        friend.setValue(friendModel.photo, forKey: "photo")
        friend.setValue(friendModel.username, forKey: "username")
        friend.setValue(friendModel.phone, forKey: "phone")
        friend.setValue(friendModel.language, forKey: "language")
        
        do {
            try self.context.save()
        } catch {
            print("Failed")
        }
    }
    
    public func getFriends() -> [FriendModel] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        var models = Array<FriendModel>()
        
        do {
            let friends = try self.context.fetch(request) as! [Friend]
            models = Array<Friend>.toFriendModel(friends: friends)
            print(models.count)
        } catch {
            print("Failed")
        }
        
        return models
    }
    
    public func getFriendLanguage(id: Int) -> String {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        var language = ""
        
        request.predicate = NSPredicate(format: "id == %@", String(id))
        do {
            let friend = try self.context.fetch(request).first as! Friend
            language = friend.language
        } catch {
            print("Failed")
        }
        
        return language
    }
    
    public func deleteFriends() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try self.context.execute(deleteRequest)
            try self.context.save()
        } catch {
            print("Failed")
        }
    }
}
