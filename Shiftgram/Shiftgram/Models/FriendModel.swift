import Foundation

struct FriendModel {
    let id: Int
    let photo: String
    let username: String
    
    init(id: Int, photo: String, username: String) {
        self.id = id
        self.photo = photo
        self.username = username
    }
}
