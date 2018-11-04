import Foundation
import Alamofire

class UserDataManager {
    
    private let url = "http://shiftgram.eu-central-1.elasticbeanstalk.com/api/account"
    private let OK_CODE = 200
    private let userEntity = UserEntity()
    
    public func addAccount(account: Account, completion: @escaping () -> Void) {
        let parameter = account.toParameters()
        
        Alamofire.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default).responseJSON { response in
            let id = response.result.value as! Int
            self.userEntity.addUser(id: id, phone: account.phone)
            completion()
        }
    }
    
    public func getFriendLanguage(id: Int, completion: @escaping(String) -> Void) {
        Alamofire.request(self.url + "/\(id)", method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON {response in
            let result = response.result.value as! NSDictionary
            let lang = result["Language"] as! String
            
            completion(lang)
        }
    }
    
    public func getById(completion: @escaping (AccountSettings) -> Void) {
        let accountId = self.userEntity.getUserId()
        print(accountId)
        
        Alamofire.request(self.url + "/\(accountId)", method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON {response in
            let result = response.result.value as! NSDictionary
            let accountSettings = AccountSettings(item: result)
            
            completion(accountSettings)
        }
    }
    
    public func isExistAccount(phone: String, completion: @escaping (Bool) -> Void) {
        let phoneURL = self.url + "/\(phone)"
        
        Alamofire.request(phoneURL, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON {response in
            if let code = response.response?.statusCode {
                if code == self.OK_CODE {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    public func updateAccountPhone(accountUpdate: AccountPhoneUpdate, completion: @escaping (Bool) -> Void) {
        let parameters = accountUpdate.toParameters()
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {response in
            if let code = response.response?.statusCode {
                if code == 200 {
                    self.userEntity.updateUser(value: parameters["Phone"] as! String, key: "phone")
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
    
    public func updateAccountLanguage(accountUpdate: AccountLanguageUpdate, completion: @escaping (Bool) -> Void) {
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
