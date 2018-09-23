import Foundation
import Alamofire

struct Account {
    
    let firstName: String
    let lastName: String
    let bio: String
    let username: String
    let photoUrl: String
    let gender: String
    
    init(firstName: String, lastName: String, bio: String, username: String,
         photoUrl: String, gender: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
        self.username = username
        self.gender = gender
        self.photoUrl = photoUrl
    }
    
    public func toParameters() -> Parameters {
        
        let parameter: Parameters = [
            "FirstName": self.firstName,
            "LastName": self.lastName,
            "Bio": self.bio,
            "Username": self.username,
            "PhotoUrl":self.photoUrl,
        ]
        
        return parameter
    }
}
