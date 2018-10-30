import Foundation
import UIKit
import CoreData

class UserEntity {
    
    private let appDelegate: AppDelegate
    private let context: NSManagedObjectContext
    
    init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = self.appDelegate.persistentContainer.viewContext
    }
    
    public func addUser(id: Int) {
        let entity = NSEntityDescription.entity(forEntityName: "User", in: self.context)
        let user = NSManagedObject(entity: entity!, insertInto: self.context)
        user.setValue(id, forKey: "id")
        user.setValue(Locale.current.languageCode!, forKey: "language")
        user.setValue(true, forKey: "isAuth")
        user.setValue(true, forKey: "isRegister")
        
        do {
            try self.context.save()
        } catch {
            print("Failed")
        }
    }
    
    public func updateUser(value: Any, key: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            let entity = try self.context.fetch(request).first as! NSManagedObject
            entity.setValue(value, forKey: key)
            try self.context.save()
        } catch {
            print("Failed")
        }
    }
    
    public func deleteUser() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try self.context.execute(deleteRequest)
            try self.context.save()
        } catch {
            print("Failed")
        }
    }
    
    public func getUserId() -> Int32 {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var id: Int32 = 0
        
        do {
            let users = try self.context.fetch(request)
            if users.count > 0 {
                let user = users.first as! User
                id = user.id
            }
            
        } catch {
            print("Failed")
        }
        
        return id
    }
    
    public func getUserPhone() -> String {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var phone: String = ""
        
        do {
            let users = try self.context.fetch(request)
            if users.count > 0 {
                let user = users.first as! User
                phone = user.phone!
            }
        } catch {
            print("Failed")
        }
        
        return phone
    }
    
    public func getUserLanguage() -> String {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var language = ""
        
        do {
            let user = try self.context.fetch(request).first as! User
            language = user.language!
        } catch {
            print("Failed")
        }
        
        return language
    }
    
    public func isAuth() -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var isAuth = false
        
        do {
            let users = try self.context.fetch(request)
            if users.count > 0 {
                let user = users.first as! User
                isAuth = user.isAuth
            }
        } catch {
            print("Failed")
        }
        
        return isAuth
    }
    
    public func isRegister() -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var isRegister = false
        
        do {
            let users = try self.context.fetch(request)
            if users.count > 0 {
                let user = users.first as! User
                isRegister = user.isRegister
            }
        } catch {
            print("Failed")
        }
        
        return isRegister
    }
    
    public func isSync() -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var isSync = false
        
        do {
            let users = try self.context.fetch(request)
            if users.count > 0 {
                let user = users.first as! User
                isSync = user.isSync
            }
        } catch {
            print("Failed")
        }
        
        return isSync
    }
    
    public func isExist() ->Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var isExist = false
        
        do {
            let result = try self.context.fetch(request) as! [NSManagedObject]
            
            if result.count > 0 {
                isExist = true
            }
        } catch {
            print("Failed")
        }
        
        return isExist
    }
}
