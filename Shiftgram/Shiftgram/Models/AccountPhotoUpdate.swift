import Foundation
import Alamofire

class AccountPhotoUpdate {
    
    private let id: Int
    private let photo: String
    private let updateType: String
    
    init(id: Int, photo: String, updateType: String) {
        self.id = id
        self.photo = photo
        self.updateType = updateType
    }
    
    public func toParameters() -> Parameters {
        
        let parameter: Parameters = [
            "Id": self.id,
            "PhotoUrl": self.photo,
            "UpdateType": self.updateType
        ]
        
        return parameter
    }
}
