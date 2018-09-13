import Foundation
import UIKit

struct AccountSettings {
    let initials: String
    let phone: String
    let username: String
    let photo: String
    
    init(item: NSDictionary) {
        let firstName = item["FirstName"] as! String
        let lastName = item["LastName"] as! String
        self.initials = firstName + " " + lastName
        self.phone = item["Phone"] as! String
        self.username = item["Username"] as! String
        self.photo = item["PhotoUrl"] as! String
    }
}

