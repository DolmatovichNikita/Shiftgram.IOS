import Foundation

class VideoAccessViewModel {
    
    private let videoDataManager = VideoDataManager()
    
    public func getToken(videoAccessModel: VideoAccessModel, completion: @escaping (String) -> Void) {
        self.videoDataManager.getToken(videoAccessModel: videoAccessModel) { (value) in
            completion(value)
        }
    }
}
