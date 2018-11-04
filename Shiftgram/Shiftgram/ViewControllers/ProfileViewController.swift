import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    UITextFieldDelegate{
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var segmentGender: UISegmentedControl!
    private let userViewModel = UserViewModel()
    public var phone = String()
    //private var activityIndicator: ActivityIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initControls()
        //self.activityIndicator = ActivityIndicator(view: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        //self.activityIndicator.startLoading()
        AwsHelper.uploadImage(image: self.profileImageView.image!) { response in
            let account = Account(firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, bio: self.bioTextField.text!,
                                  username: self.usernameTextField.text!, photoUrl: response, gender: self.segmentGender.titleForSegment(at: self.segmentGender.selectedSegmentIndex)!, phone: self.phone)
            self.userViewModel.addAccount(account: account) {}
            //self.activityIndicator.stopLoading()
            self.performSegue(withIdentifier: "RegisterToMenu", sender: self)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.profileImageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func initControls() {
        self.addBorderTextField()
        self.addClickToImageView()
        self.serCircleImageView()
    }
    
    private func addClickToImageView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imagePressed(tapGestureRecognizer:)))
        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func imagePressed(tapGestureRecognizer: UITapGestureRecognizer) {
        let choiceImageAlert = UIAlertController(title: "Select image from", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let cameraRollAction = UIAlertAction(title: "Camera Roll", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        choiceImageAlert.addAction(cameraAction)
        choiceImageAlert.addAction(cameraRollAction)
        self.present(choiceImageAlert, animated: true, completion: nil)
    }
    
    private func addBorderTextField() {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.gray.cgColor
        border.frame = CGRect(x: 0, y: firstNameTextField.frame.size.height - width, width: firstNameTextField.frame.size.width, height: firstNameTextField.frame.size.height)
        border.borderWidth = width
        firstNameTextField.layer.addSublayer(border)
        firstNameTextField.layer.masksToBounds = true
    }
    
    private func serCircleImageView() {
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }
}
