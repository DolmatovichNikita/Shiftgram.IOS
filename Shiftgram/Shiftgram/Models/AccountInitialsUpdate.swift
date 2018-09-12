import Foundation
import Alamofire

class AccountInitialsUpdate {
    private let id: Int
    private let firstName: String
    private let lastName: String
    private let updateType: String
    
    init(id: Int, firstName: String, lastName: String, updateType: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.updateType = updateType
    }
    
    public func toParameters() -> Parameters {
        let parameter: Parameters = [
            "Id": self.id,
            "FirstName": self.firstName,
            "LastName": self.lastName,
            "UpdateType": self.updateType
        ]
        
        return parameter
    }
}
