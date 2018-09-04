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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnStartMessagingPressed(_ sender: Any) {
    }
    
    private func initControls() {
        btnStartMessaging.layer.cornerRadius = 20
    }
}

