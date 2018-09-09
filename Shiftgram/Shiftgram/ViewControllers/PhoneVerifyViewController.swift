//
//  PhoneVerifyViewController.swift
//  Shiftgram
//
//  Created by Nikita on 04.09.2018.
//  Copyright © 2018 SolIT. All rights reserved.
//

import UIKit

class PhoneVerifyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var phonePicker: UIPickerView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    var activityIndicator: ActivityIndicator!
    var phoneViewModel = PhoneViewModel()
    var phones = [Phone]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initControls()
        self.activityIndicator = ActivityIndicator(view: self.view)
        self.activityIndicator.startLoading()
        phonePicker.delegate = self
        phonePicker.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getPhones()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return phones.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return phones[row].country
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        codeLabel.text = phones[row].code
    }
    
    private func getPhones() {
        self.phoneViewModel.getPhones {
            self.phones = Array(self.phoneViewModel.phones)
            self.codeLabel.text = self.phones.first?.code
            self.phonePicker.reloadAllComponents()
            self.activityIndicator.stopLoading()
        }
    }
    
    private func initControls() {
        self.btnNext.layer.cornerRadius = 20
        self.addBorderTextField()
    }
    
    private func addBorderTextField() {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.gray.cgColor
        border.frame = CGRect(x: 0, y: numberTextField.frame.size.height - width, width: numberTextField.frame.size.width, height: numberTextField.frame.size.height)
        border.borderWidth = width
        numberTextField.layer.addSublayer(border)
        numberTextField.layer.masksToBounds = true
    }
}
