import Foundation
import Alamofire

class AccountGenderUpdate {
    private let id: Int
    private let gender: String
    private let updateType: String
    
    init(id: Int, gender: String, updateType: String) {
        self.id = id
        self.gender = gender
        self.updateType = updateType
    }
    
    public func toParameters() -> Parameters {
        let parameter: Parameters = [
            "Id": self.id,
            "GenderName": self.gender,
            "UpdateType": self.updateType
        ]
        
        return parameter
    }
}
