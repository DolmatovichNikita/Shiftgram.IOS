import Foundation
import Alamofire

class FriendDataManager {
    private let url = "http://shiftgram.eu-central-1.elasticbeanstalk.com/api/friend"
    
    public func addFriend(accountFriendModel: AccountFriendModel, completion: @escaping () -> Void) {
        let parameters = accountFriendModel.toParameters()
        
        Alamofire.request(self.url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response in
            if let code = response.response?.statusCode {
                print(code)
                completion()
            }
        }
    }
}
