import Foundation

class FriendViewModel {
    
    private let friendDataManager = FriendDataManager()
    
    public func syncFriends(accountFriendModel: AccountFriendModel, completion: @escaping () -> Void) {
        self.friendDataManager.addFriend(accountFriendModel: accountFriendModel) { response in
            completion()
        }
    }
}
