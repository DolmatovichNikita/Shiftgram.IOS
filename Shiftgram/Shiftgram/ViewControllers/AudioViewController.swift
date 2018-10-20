import UIKit

class AudioViewController: UIViewController {
    
    public var name = String()
    public var conversationName = String()
    public var friendLanguage = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        self.initControls()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func initControls() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 4)
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(30)
        label.textColor = UIColor.white
        label.text = name
        
        let labelContacting = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        labelContacting.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 4 + 100)
        labelContacting.textAlignment = NSTextAlignment.center
        labelContacting.font = labelContacting.font.withSize(30)
        labelContacting.textColor = UIColor.white
        labelContacting.text = "Contacting ..."
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        cancelButton.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - 100)
        cancelButton.backgroundColor = UIColor.red
        cancelButton.setImage(UIImage(named: "endCall"), for: .normal)
        cancelButton.layer.cornerRadius = 27
        
        self.view.addSubview(label)
        self.view.addSubview(labelContacting)
        self.view.addSubview(cancelButton)
    }
}
