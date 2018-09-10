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
    
    private let urlPhone = "http://shiftgram.eu-central-1.elasticbeanstalk.com/api/phone"
    private let urlVerify = "http://shiftgram.eu-central-1.elasticbeanstalk.com/api/phoneverify"
    
    public func getPhones(completion: @escaping ([Phone]) -> Void) {
        Alamofire.request(urlPhone, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON {
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
    
    public func sendSMS(phoneVerify: PhoneVerify, completion: @escaping () -> Void) {
        let id = phoneVerify.id
        var code = phoneVerify.code
        code.remove(at: code.startIndex)
        let phone = code + phoneVerify.number
        Alamofire.request(urlVerify + "/SendSMS/\(id)/\(phone)", method: .get).responseJSON { _ in
            completion()
        }
    }
    
    public func isAuth(phoneVerify: PhoneVerify, completion: @escaping (Bool) -> Void) {
        let parameters = phoneVerify.toParameters()
        print(parameters)
        Alamofire.request(urlVerify, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {response in
            print(response)
            if let code = response.response?.statusCode {
                if code == 200 {
                    completion(true)
                } else if code == 400 {
                    completion(false)
                }
            }
        }
    }
}
