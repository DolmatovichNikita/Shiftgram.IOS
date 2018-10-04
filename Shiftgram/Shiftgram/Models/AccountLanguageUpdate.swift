import Foundation
import Alamofire

struct AccountLanguageUpdate {
    
    private let id: Int!
    private let language: String!
    private let updateType: String!
    
    init(id: Int, language: String, updateType: String) {
        self.id = id
        self.language = language
        self.updateType = updateType
    }
    
    public func toParameters() -> Parameters {
        let parameter: Parameters = [
            "Id": self.id,
            "Language": self.language,
            "UpdateType": self.updateType
        ]
        
        return parameter
    }
}
