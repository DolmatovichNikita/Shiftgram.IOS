import Foundation
import Alamofire

class FriendDataManager {
    private let url = "http://shiftgram.eu-central-1.elasticbeanstalk.com/api/friend"
    
    public func addFriend(accountFriendModel: AccountFriendModel, completion: @escaping () -> Void) {
        let parameters = accountFriendModel.toParameters()

        Alamofire.request(self.url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response in
            completion()
        }
    }
    
    public func getFriends(completion: @escaping () -> Void) {
        let userId = UserEntity().getUserId()
        
        Alamofire.request(self.url + "/\(userId)", method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON {response in
            if let result = response.result.value {
                let items = result as! NSArray
                for item in items {
                    let value = item as! NSDictionary
                    let friendEntity = FriendEntity()
                    let friendModel = FriendModel(id: value["Id"] as! Int, photo: value["PhotoUrl"] as! String)
                    friendEntity.addFriend(friendModel: friendModel)
                }
            }
        }
    }
}
