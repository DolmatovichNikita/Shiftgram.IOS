import UIKit

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.serCircleImageView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func serCircleImageView() {
        contactImageView.layer.borderWidth = 1
        contactImageView.layer.masksToBounds = false
        contactImageView.layer.borderColor = UIColor.black.cgColor
        contactImageView.layer.cornerRadius = contactImageView.frame.height/2
        contactImageView.clipsToBounds = true
        contactImageView.contentMode = .scaleAspectFill
    }
}
