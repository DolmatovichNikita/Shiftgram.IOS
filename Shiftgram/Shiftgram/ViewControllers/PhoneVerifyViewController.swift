import UIKit

class PhoneVerifyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var phonePicker: UIPickerView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    private var activityIndicator: ActivityIndicator!
    private var phoneViewModel = PhoneViewModel()
    private var phones = [Phone]()
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Register" {
            let registerViewController = segue.destination as? ProfileViewController
            registerViewController?.phone = codeLabel.text! + numberTextField.text!
        }
    }
    
    @IBAction func btnNextPressed(_ sender: Any) {
        //self.activityIndicator.startLoading()
        let phone = codeLabel.text! + numberTextField.text!
        
        //self.phoneViewModel.isExistUser(phone: phone, completion: { (response) in
            //if !response {
                self.performSegue(withIdentifier: "Register", sender: self)
            //} else {
                //self.performSegue(withIdentifier: "Menu", sender: self)
            //}
        //})
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
