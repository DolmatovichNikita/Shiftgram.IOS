import Foundation
import Alamofire

struct VideoAccessModel {
    
    private let name: String
    private let room: String
    
    public func toParameters() -> Parameters {
        let parameter: Parameters = [
            "Name": self.name,
            "Room": self.room
        ]
        
        return parameter
    }
}
