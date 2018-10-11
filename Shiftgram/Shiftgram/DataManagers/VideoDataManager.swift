import Foundation
import Alamofire

class VideoDataManager {
    
    private let URL = "http://shiftgram.eu-central-1.elasticbeanstalk.com/api/videoaccess"
    
    public func getToken(videoAccessModel: VideoAccessModel, completion: @escaping (String) -> Void) {
        let parameters = videoAccessModel.toParameters()
        
        Alamofire.request(self.URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            let token = response.result.value as! String
            
            completion(token)
        }
    }
}
