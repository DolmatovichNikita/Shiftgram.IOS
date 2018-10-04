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
    
    public func isExistAccount(phone:String, completion: @escaping (Bool) -> Void) {
        self.userDataManager.isExistAccount(phone: phone) {response in
            completion(response)
        }
    }
    
    public func updateLanguage(accountUpdate: AccountLanguageUpdate, completion: @escaping (Bool) -> Void) {
        self.userDataManager.updateAccountLanguage(accountUpdate: accountUpdate) { (value) in
            completion(value)
        }
    }
}
