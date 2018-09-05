//
//  CodeVerifyViewController.swift
//  Shiftgram
//
//  Created by Nikita on 05.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

import UIKit

class CodeVerifyViewController: UIViewController {

    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func initControls() {
        self.addBorderTextField()
    }
    
    private func addBorderTextField() {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.gray.cgColor
        border.frame = CGRect(x: 0, y: codeTextField.frame.size.height - width, width: codeTextField.frame.size.width, height: codeTextField.frame.size.height)
        border.borderWidth = width
        codeTextField.layer.addSublayer(border)
        codeTextField.layer.masksToBounds = true
    }
}
