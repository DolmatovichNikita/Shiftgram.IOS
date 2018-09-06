//
//  PhoneDataManager.swift
//  Shiftgram
//
//  Created by Nikita on 05.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

import Foundation
import Alamofire

class PhoneDataManager {
    
    private let url = "http://shiftgram.eu-central-1.elasticbeanstalk.com/api/phone";
    
    public func getPhones(completion: @escaping ([Phone]) -> Void) {
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON {
            response in
            var phones = [Phone]()
            if let result = response.result.value {
                let items = result as! NSArray
                for item in items {
                    let phone = Phone(item: item as! NSDictionary)
                    phones.append(phone)
                }
            }
            completion(phones)
        }
    }
}
