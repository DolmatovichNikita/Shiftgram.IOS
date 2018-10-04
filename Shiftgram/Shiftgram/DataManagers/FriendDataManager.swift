import Foundation
import Alamofire

class FriendDataManager {
    
    private let url = "http://shiftgram.eu-central-1.elasticbeanstalk.com/api/friend"
    private let OK_CODE = 200
    private let userId = UserEntity().getUserId()
    
    public func addFriend(accountFriendModel: AccountFriendModel, completion: @escaping (Bool) -> Void) {
        let parameters = accountFriendModel.toParameters()

        Alamofire.request(self.url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response in
            if let code = response.response?.statusCode {
                if code == self.OK_CODE {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    public func fetchFriends(completion: @escaping () -> Void) {
        Alamofire.request(self.url + "/\(userId)", method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON {response in
            if let result = response.result.value {
                let items = result as! NSArray
                for item in items {
                    let value = item as! NSDictionary
                    if FriendEntity().getFriends().count > 0 {
                        for friend in FriendEntity().getFriends() {
                            if friend.id != value["Id"] as! Int {
                                let friendEntity = FriendEntity()
                                let friendModel = FriendModel(id: value["Id"] as! Int, photo: value["PhotoUrl"] as! String,
                                                              username: value["Username"] as! String, phone: value["Phone"] as! String, language: value["Language"] as! String)
                                friendEntity.addFriend(friendModel: friendModel)
                            }
                        }
                    } else {
                        let friendEntity = FriendEntity()
                        let friendModel = FriendModel(id: value["Id"] as! Int, photo: value["PhotoUrl"] as! String,
                                                      username: value["Username"] as! String, phone: value["Phone"] as! String, language: value["Language"] as! String)
                        friendEntity.addFriend(friendModel: friendModel)
                    }
                }
                
                completion()
            }
        }
    }
    
    public func updateLanguageFriends(completion: @escaping () -> Void) {
        Alamofire.request(self.url + "/\(userId)", method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
            if let result = response.result.value {
                let items = result as! NSArray
                for item in items {
                    let value = item as! NSDictionary
                    FriendEntity().updateFriend(value: value["Language"] as! String, key: "language", id: value["Id"] as! Int)
                }
            }
            
            completion()
        }
    }
}
