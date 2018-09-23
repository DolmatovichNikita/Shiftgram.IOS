import Foundation
import Alamofire

struct AccountFriendModel {
    
    let accountAId: Int
    let accountBPhone: String
    
    public func toParameters() -> Parameters {
        
        let accountfriendModel: Parameters = [
            "AccountAId": self.accountAId,
            "AccountBPhone": self.accountBPhone
        ]
        
        return accountfriendModel
    }
}
