//
//  ViewController.swift
//  Shiftgram
//
//  Created by Nikita on 04.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var btnStartMessaging: UIButton!
    private let userEntity = UserEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnStartMessagingPressed(_ sender: Any) {
        let isExist = self.userEntity.isExist()
        
        if isExist {
            self.performSegue(withIdentifier: "PhoneVerify", sender: self)
        } else {
            self.performSegue(withIdentifier: "Register", sender: self)
        }
    }
    
    private func initControls() {
        btnStartMessaging.layer.cornerRadius = 20
    }
}

