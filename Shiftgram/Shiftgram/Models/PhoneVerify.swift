//
//  PhoneVerify.swift
//  Shiftgram
//
//  Created by Nikita on 09.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

import Foundation
import Alamofire

struct PhoneVerify {
    let id: Int
    let number: String
    let code: String
    
    init(id: Int, number: String, code: String) {
        self.id = id
        self.number = number
        self.code = code
    }
    
    public func toParameters() -> Parameters {
        let parameter: Parameters = [
            "Id": self.id,
            "Number": self.number,
            "Code": self.code
        ]
        
        return parameter
    }
}
