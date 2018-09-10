//
//  AccountUpdateModel.swift
//  Shiftgram
//
//  Created by Nikita on 10.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

import Foundation
import Alamofire

struct AccountUpdate {
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
