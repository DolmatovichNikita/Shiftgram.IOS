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
        } catch {
            print("Failed")
        }
        
        return models
    }
}
