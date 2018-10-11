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
    
    @IBAction func btnDisconnectPressed(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.startPreview()
    }
    
    private func startPreview() {
        self.camera = TVICameraCapturer(source: .frontCamera, delegate: self)
        self.localVideoTrack = TVILocalVideoTrack.init(capturer: camera!, enabled: true, constraints: nil, name: "Camera")
        if (localVideoTrack == nil) {
            print("Failed to create video track")
        } else {
            self.localVideoTrack!.addRenderer(self.previewView)
            let tap = UITapGestureRecognizer(target: self, action: #selector(flipCamera))
            self.previewView.addGestureRecognizer(tap)
        }
    }
    
    @objc private func flipCamera() {
        if (self.camera?.source == .frontCamera) {
            self.camera?.selectSource(.backCameraWide)
        } else {
            self.camera?.selectSource(.frontCamera)
        }
    }
}

extension VideoViewController : TVICameraCapturerDelegate {
    func cameraCapturer(_ capturer: TVICameraCapturer, didStartWith source: TVICameraCaptureSource) {
        self.previewView.shouldMirror = (source == .frontCamera)
    }
}
