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
    
    public func sendSMS(accountUpdate: AccountPhoneUpdate?, phoneVerify: PhoneVerify, completion: @escaping () -> Void) {
        if accountUpdate != nil {
            let userEntity = UserEntity()
            userEntity.updateUser(value: true, key: "isRegister")
            self.userDataManager.updateAccountPhone(accountUpdate: accountUpdate!) {response in
                if response {
                    //self.phoneDataManager.sendSMS(phoneVerify: phoneVerify) {
                        completion()
                    //}
                }
            }
        } else {
            self.phoneDataManager.sendSMS(phoneVerify: phoneVerify) {
                completion()
            }
        }
    }
    
    public func isAuth(phoneVerify: PhoneVerify, completion: @escaping (Bool) -> Void) {
        //self.phoneDataManager.isAuth(phoneVerify: phoneVerify) {response in
            //if response {
                let userEntity = UserEntity()
                userEntity.updateUser(value: true, key: "isAuth")
            //}
            completion(true) //swap completion(response)
        //}
    }
    
    public func isExistUser(phone: String, completion: @escaping(Bool) -> Void) {
        self.userDataManager.isExistAccount(phone: phone) { (value) in
            completion(value)
        }
    }
}
