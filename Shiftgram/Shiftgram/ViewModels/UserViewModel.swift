import Foundation

class UserViewModel {
    private let userDataManager = UserDataManager()
    
    public func addAccount(account: Account, completion: @escaping() -> Void) {
        self.userDataManager.addAccount(account: account) {
            completion()
        }
    }
}
