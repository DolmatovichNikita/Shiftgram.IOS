import Foundation
import Alamofire

class AccountUsernameUpdate {
    
    private let id: Int
    private let username: String
    private let updateType: String
    
    init(id: Int, username: String, updateType: String) {
        self.id = id
        self.username = username
        self.updateType = updateType
    }
    
    public func toParameters() -> Parameters {
        
        let parameter:Parameters = [
            "Id": self.id,
            "Username": self.username,
            "UpdateType": self.updateType
        ]
        
        return parameter
    }
}
