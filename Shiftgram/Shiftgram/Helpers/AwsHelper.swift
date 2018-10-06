import Foundation
import UIKit
import AWSCore
import AWSS3
import AVFoundation

class AwsHelper {
    
    public static func uploadImage(image: UIImage, completion: @escaping (String) -> Void) {
        let transferManager = AWSS3TransferManager.default()
        let bucketName = "shiftgramimage"
        let jpgImage = UIImageJPEGRepresentation(image, 1)
        let fileName = "test.jpg"
        let fileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        do {
            try jpgImage?.write(to: fileUrl)
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest?.body = fileUrl
            uploadRequest?.key = ProcessInfo.processInfo.globallyUniqueString + ".jpg"
            uploadRequest?.bucket = bucketName
            uploadRequest?.contentType = "image/jpg"
            
            transferManager.upload(uploadRequest!).continueWith { (task) -> Any? in
                if let error = task.error {
                    print(error)
                } else {
                    DispatchQueue.main.async {
                        completion((uploadRequest?.key)!)
                    }
                }
                return nil
            }
        } catch {
            print("failed")
        }
    }
    
    public static func downloadImage(path: String, completion: @escaping (NSData) -> Void) {
        let bucketName = "shiftgramimage"
        let key = path
        let transferManager = AWSS3TransferManager.default()
        let downloadedFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test.jpg")
        
        if let downloadedRequest = AWSS3TransferManagerDownloadRequest(){
            downloadedRequest.bucket = bucketName
            downloadedRequest.key = key
            downloadedRequest.downloadingFileURL = downloadedFile
            
            transferManager.download(downloadedRequest).continueWith { (task) -> Any? in
                if let error = task.error {
                    print(error)
                } else {
                    if let data = NSData(contentsOf: downloadedFile) {
                        DispatchQueue.main.async {
                            completion(data)
                        }
                    }
                }
                
                return nil
            }
        }
    }
    
    public static func uploadRecord(audioRecord: AVAudioRecorder, completion: @escaping (String) -> Void) {
        let transferManager = AWSS3TransferManager.default()
        let bucketName = "shiftgramaudio"
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = audioRecord.url
        uploadRequest?.key = ProcessInfo.processInfo.globallyUniqueString + ".caf"
        uploadRequest?.bucket = bucketName
        uploadRequest?.contentType = "audio/caf"
        
        transferManager.upload(uploadRequest!).continueWith { (task) -> Any? in
            if let error = task.error {
                print(error)
            } else {
                DispatchQueue.main.async {
                    completion((uploadRequest?.key)!)
                }
            }
            
            return nil
        }
    }
    
    public static func downloadRecord(path: String, completion: @escaping (NSData) -> Void) {
        let bucketName = "shiftgramaudio"
        let key = path
        let transferManage = AWSS3TransferManager.default()
        let downloadedFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("sound.caf")
        
        let downloadedRequest = AWSS3TransferManagerDownloadRequest()
        downloadedRequest?.bucket = bucketName
        downloadedRequest?.key = key
        downloadedRequest?.downloadingFileURL = downloadedFile
        
        transferManage.download(downloadedRequest!).continueWith { (task) -> Any? in
            if let error = task.error {
                print(error)
            } else {
                if let data = NSData(contentsOf: downloadedFile) {
                    DispatchQueue.main.async {
                        completion(data)
                    }
                }
            }
            
            return nil
        }
    }
}
