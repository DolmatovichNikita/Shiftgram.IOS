import UIKit

class InitialViewController: UIViewController {
    
    @IBOutlet weak var btnStartMessaging: UIButton!
    private let userEntity = UserEntity()
    private let userViewModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnStartMessagingPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "PhoneVerify", sender: self)
    }
    
    private func initControls() {
        btnStartMessaging.layer.cornerRadius = 20
    }
}

