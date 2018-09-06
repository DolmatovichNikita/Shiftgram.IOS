//
//  Phone.swift
//  Shiftgram
//
//  Created by Nikita on 05.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

import Foundation

struct Phone {
    let id: Int
    let country: String
    let code: String
    
    init(item: NSDictionary) {
        self.id = item["Id"] as! Int
        self.country = item["Country"] as! String
        self.code = item["Code"] as! String
    }
}
