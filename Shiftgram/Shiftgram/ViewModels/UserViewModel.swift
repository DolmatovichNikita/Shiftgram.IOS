import Foundation

class UserViewModel {
    private let userDataManager = UserDataManager()
    
    public func addAccount(account: Account, completion: @escaping() -> Void) {
        self.userDataManager.addAccount(account: account) {
            completion()
        }
    }
    
    public func getAccountSettings(completion: @escaping (AccountSettings) -> Void) {
        self.userDataManager.getById {response in
            completion(response)
        }
    }
}
