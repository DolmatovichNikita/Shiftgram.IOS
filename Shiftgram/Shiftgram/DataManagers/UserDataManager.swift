//
//  UserDataManager.swift
//  Shiftgram
//
//  Created by Nikita on 09.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

import Foundation
import Alamofire

class UserDataManager {
    
    private let url = "http://shiftgram.eu-central-1.elasticbeanstalk.com/api/account"
    private let userEntity = UserEntity()
    
    public func addAccount(account: Account, completion: @escaping () -> Void) {
        let parameter = account.toParameters()
        
        Alamofire.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default).responseJSON {
            response in
            let id = response.result.value as! Int
            self.userEntity.addUser(id: id)
            completion()
        }
    }
}
