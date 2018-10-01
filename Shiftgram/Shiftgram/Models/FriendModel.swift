import Foundation

struct FriendModel {
    let id: Int
    let photo: String
    let username: String
    let phone: String
    
    init(id: Int, photo: String, username: String, phone: String) {
        self.id = id
        self.photo = photo
        self.username = username
        self.phone = phone
    }
}
