import Foundation
import Alamofire

class AccountBioUpdate {
    private let id: Int
    private let bio: String
    private let updateType: String
    
    init(id: Int, bio: String, updateType: String) {
        self.id = id
        self.bio = bio
        self.updateType = updateType
    }
    
    public func toParameters() -> Parameters {
        let parameter: Parameters = [
            "Id": self.id,
            "Bio": self.bio,
            "UpdateType": self.updateType
        ]
        
        return parameter
    }
}
