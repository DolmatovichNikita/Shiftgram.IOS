//
//  Account.swift
//  Shiftgram
//
//  Created by Nikita on 09.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

import Foundation
import Alamofire

struct Account {
    let id: Int
    let firstName: String
    let lastName: String
    let bio: String
    let username: String
    let photoUrl: String
    let gender: String
    
    init(id: Int, firstName: String, lastName: String, bio: String, username: String,
         photoUrl: String, gender: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
        self.username = username
        self.gender = gender
        self.photoUrl = photoUrl
    }
    
    public func toParameters() -> Parameters {
        
        let parameter: Parameters = [
            "Id": self.id,
            "FirstName": self.firstName,
            "LastName": self.lastName,
            "Bio": self.bio,
            "Username": self.username,
            "PhotoUrl":self.photoUrl,
        ]
        
        return parameter
    }
}
