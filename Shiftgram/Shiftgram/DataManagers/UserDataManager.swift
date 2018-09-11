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
    
    public func updateAccount(accountUpdate: AccountUpdate, completion: @escaping (Bool) -> Void) {
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
}
