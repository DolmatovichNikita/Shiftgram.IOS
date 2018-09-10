import Foundation

class PhoneViewModel {
    private let phoneDataManager = PhoneDataManager()
    private let userDataManager = UserDataManager()
    var phones = [Phone]()
    
    public func getPhones(completion: @escaping () -> Void) {
        self.phoneDataManager.getPhones {response in
            self.phones = response
            completion()
        }
    }
    
    public func sendSMS(accountUpdate: AccountUpdate?, phoneVerify: PhoneVerify, completion: @escaping () -> Void) {
        if accountUpdate != nil {
            self.userDataManager.updateAccount(accountUpdate: accountUpdate!) {response in
                if response {
                    self.phoneDataManager.sendSMS(phoneVerify: phoneVerify) {
                        completion()
                    }
                }
            }
        } else {
            self.phoneDataManager.sendSMS(phoneVerify: phoneVerify) {
                completion()
            }
        }
    }
    
    public func isAuth(phoneVerify: PhoneVerify, completion: @escaping (Bool) -> Void) {
        self.phoneDataManager.isAuth(phoneVerify: phoneVerify) {response in
            completion(response)
        }
    }
}
