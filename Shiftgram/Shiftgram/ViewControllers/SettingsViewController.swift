import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    private let userViewModel = UserViewModel()
    private var activityIndicator: ActivityIndicator!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initControls()
        UINavigationBar.appearance().backgroundColor = self.view.backgroundColor
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        self.activityIndicator = ActivityIndicator(view: self.view)
        self.activityIndicator.startLoading()
        self.getAccountSettings()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnLanguagePressed(_ sender: Any) {
        self.activityIndicator.startLoading()
        let accountUpdate = AccountLanguageUpdate(id: Int(UserEntity().getUserId()), language: (Locale.preferredLanguages.first?.parseLanguage())!, updateType: "LanguageUpdate")
        self.userViewModel.updateLanguage(accountUpdate: accountUpdate) { (_) in
            self.userViewModel.updateLanguageFriend(completion: {
                self.activityIndicator.stopLoading()
            })
        }
    }
    
    private func getAccountSettings() {
        self.userViewModel.getAccountSettings {response in
            let scope = self
            self.initialsLabel.text = response.initials
            self.phoneLabel.text = response.phone
            self.usernameLabel.text = response.username
            AwsHelper.downloadImage(path: response.photo) {data in
                scope.profileImageView.image = UIImage(data: data as Data)
                scope.activityIndicator.stopLoading()
            }
        }
    }
    
    private func initControls() {
        self.serCircleImageView()
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
