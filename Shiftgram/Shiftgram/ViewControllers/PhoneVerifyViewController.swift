//
//  PhoneVerifyViewController.swift
//  Shiftgram
//
//  Created by Nikita on 04.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

import UIKit

class PhoneVerifyViewController: UIViewController {

    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func initControls() {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.gray.cgColor
        border.frame = CGRect(x: 0, y: numberTextField.frame.size.height - width, width: numberTextField.frame.size.width, height: numberTextField.frame.size.height)
        
        border.borderWidth = width
        numberTextField.layer.addSublayer(border)
        numberTextField.layer.masksToBounds = true
    }
}
