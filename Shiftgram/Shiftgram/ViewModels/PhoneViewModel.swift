//
//  PhoneViewModel.swift
//  Shiftgram
//
//  Created by Nikita on 05.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

import Foundation

class PhoneViewModel {
    
    private let phoneDataManager = PhoneDataManager()
    var phones = [Phone]()
    
    public func getPhones(completion: @escaping () -> Void) {
        self.phoneDataManager.getPhones { response in
            self.phones = response
            completion()
        }
    }
    
    public func sendSMS(phoneVerify: PhoneVerify, completion: @escaping () -> Void) {
        self.phoneDataManager.sendSMS(phoneVerify: phoneVerify) {
            completion()
        }
    }
    
    public func isAuth(phoneVerify: PhoneVerify, completion: @escaping (Bool) -> Void) {
        self.phoneDataManager.isAuth(phoneVerify: phoneVerify) {response in
            completion(response)
        }
    }
}
