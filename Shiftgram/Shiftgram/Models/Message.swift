import Foundation

struct Message {
    
    let id: String?
    let text: String?
    let language: String?
    let isAudio: Bool
    let sentDate: Date
    
    init(userId: Int, text: String, language: String, isAudio: Bool) {
        self.text = text
        self.language = language
        self.isAudio = isAudio
        self.sentDate = Date()
    }
}
