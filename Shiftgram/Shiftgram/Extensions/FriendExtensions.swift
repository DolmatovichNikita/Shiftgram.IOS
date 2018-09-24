import Foundation

extension Array where Element: Friend {
    
    static func toFriendModel(friends: [Friend]) -> [FriendModel] {
        var models = [FriendModel]()
        
        for friend in friends {
            let model = FriendModel(id: Int(friend.id), photo: friend.photo!, username: friend.username!)
            models.append(model)
        }
        
        return models
    }
}
