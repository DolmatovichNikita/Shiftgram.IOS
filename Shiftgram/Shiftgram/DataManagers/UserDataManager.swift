import Foundation
import Alamofire

class UserDataManager {
    private let url = "http://shiftgram.eu-central-1.elasticbeanstalk.com/api/account"
    private let userEntity = UserEntity()
    
    public func addAccount(account: Account, completion: @escaping () -> Void) {
        let parameter = account.toParameters()
        
        Alamofire.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default).responseJSON { response in
            let id = response.result.value as! Int
            self.userEntity.addUser(id: id)
            completion()
        }
    }
    
    public func getById(completion: @escaping (AccountSettings) -> Void) {
        let accountId = self.userEntity.getUserId()
        
        Alamofire.request(self.url + "/\(accountId)", method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON {response in
            let result = response.result.value as! NSDictionary
            let accountSettings = AccountSettings(item: result)
            
            completion(accountSettings)
        }
    }
    
    public func updateAccountPhone(accountUpdate: AccountPhoneUpdate, completion: @escaping (Bool) -> Void) {
        let parameters = accountUpdate.toParameters()
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {response in
            if let code = response.response?.statusCode {
                if code == 200 {
                    completion(true)
                } else if code == 400 {
                    completion(false)
                }
            }
        }
    }
    
    public func updateAccountInitials(accountUpdate: AccountInitialsUpdate, completion: @escaping (Bool) -> Void) {
        let parameters = accountUpdate.toParameters()
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response in
            if let code = response.response?.statusCode {
                if code == 200 {
                    completion(true)
                } else if code == 400 {
                    completion(false)
                }
            }
        }
    }
    
    public func updateAccountBio(accountUpdate: AccountBioUpdate, completion: @escaping (Bool) -> Void) {
        let parameters = accountUpdate.toParameters()
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response in
            if let code = response.response?.statusCode {
                if code == 200 {
                    completion(true)
                } else if code == 400 {
                    completion(false)
                }
            }
        }
    }
    
    public func updateAccountUsername(accountUpdate: AccountUsernameUpdate, completion: @escaping (Bool) -> Void) {
        let parameters = accountUpdate.toParameters()
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response in
            if let code = response.response?.statusCode {
                if code == 200 {
                    completion(true)
                } else if code == 400 {
                    completion(false)
                }
            }
        }
    }
    
    public func updateAccountPhoto(accountUpdate: AccountPhotoUpdate, completion: @escaping (Bool) -> Void) {
        let parameters = accountUpdate.toParameters()
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response in
            if let code = response.response?.statusCode {
                if code == 200 {
                    completion(true)
                } else if code == 400 {
                    completion(false)
                }
            }
        }
    }
    
    public func updateAccountGender(accountUpdate: AccountGenderUpdate, completion: @escaping (Bool) -> Void) {
        let parameters = accountUpdate.toParameters()
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response in
            if let code = response.response?.statusCode {
                if code == 200 {
                    completion(true)
                } else if code == 400 {
                    completion(false)
                }
            }
        }
    }
}
