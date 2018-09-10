import UIKit

class CodeVerifyViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    let phoneViewModel = PhoneViewModel()
    let userEntity = UserEntity()
    var phone = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func btnNextPressed(_ sender: Any) {
        let userEntity = UserEntity()
        let id = userEntity.getUserId()
        let phoneVerify = PhoneVerify(id: Int(id), number: phone, code: codeTextField.text!)
        self.phoneViewModel.isAuth(phoneVerify: phoneVerify) { response in
            if response {
                if !self.userEntity.isRegister() {
                    self.userEntity.updateUser(value: true, key: "isRegister")
                    self.userEntity.updateUser(value: true, key: "isAuth")
                }
                self.performSegue(withIdentifier: "Menu", sender: self)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return true
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
