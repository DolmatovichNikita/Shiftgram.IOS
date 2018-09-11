import Foundation
import Alamofire

class AccountUpdate {
    let id: Int
    let phone: String
    let updateType: String
    
    init(id: Int, phone: String, updateType: String) {
        self.id = id
        self.phone = phone
        self.updateType = updateType
    }
    
    public func toParameters() -> Parameters {
        let parameter: Parameters = [
            "Id": self.id,
            "Phone": self.phone,
            "UpdateType": self.updateType
        ]
        
        return parameter
    }
}
