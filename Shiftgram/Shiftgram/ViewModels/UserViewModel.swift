//
//  UserViewModel.swift
//  Shiftgram
//
//  Created by Nikita on 09.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

import Foundation

class UserViewModel {
    private let userDataManager = UserDataManager()
    
    public func addAccount(account: Account, completion: @escaping() -> Void) {
        self.userDataManager.addAccount(account: account) {
            completion()
        }
    }
}
