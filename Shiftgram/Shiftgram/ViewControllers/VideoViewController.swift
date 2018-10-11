import UIKit
import TwilioVideo

class VideoViewController: UIViewController {

    public var conversationName: String?
    public var friendLaguage: String?
    private var accessToken: String?
    private let videoAccessViewModel = VideoAccessViewModel()
    
    private var room: TVIRoom?
    private var camera: TVICameraCapturer?
    private var localVideoTrack: TVILocalVideoTrack?
    private var localAudioTrack: TVILocalAudioTrack?
    private var remoteParticipant: TVIRemoteParticipant?
    private var remoteView: TVIVideoView?
    
    @IBOutlet weak var previewView: TVIVideoView!
    
    @IBAction func pressedBtnDisconnect(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
}
