//
//  User.swift
//  Shiftgram
//
//  Created by Nikita on 09.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

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
