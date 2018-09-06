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
}
