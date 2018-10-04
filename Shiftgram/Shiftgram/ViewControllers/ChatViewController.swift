import UIKit
import JSQMessagesViewController
import ROGoogleTranslate

class ChatViewController: JSQMessagesViewController {
    
    public var conversationName = String()
    public var friendLanguage = String()
    private var messages = [JSQMessage]()
    private let userId = UserEntity().getUserId()
    private var language = (Locale.preferredLanguages.first?.parseLanguage())!
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.lightGray)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.initChat()
    }
    
    private func initChat() {
        senderId = String(userId)
        senderDisplayName = String(userId)
        title = "Chat: \(senderDisplayName!)"
        
        let query = Constants.refs.databaseRoot.child(self.conversationName).queryLimited(toLast: 10)
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            
            if  let data        = snapshot.value as? [String: String],
                let id          = data["sender_id"],
                let name        = data["name"],
                let text        = data["sender_id"] == self!.senderId ? data["ownText"] : data["transText"],
                !text.isEmpty
            {
                
                
                if let message = JSQMessage(senderId: id, displayName: name, text: text)
                {
                    self?.messages.append(message)
                            
                    self?.finishReceivingMessage()
                }
                
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let ref = Constants.refs.databaseRoot.child(self.conversationName).childByAutoId()
        
        let params = ROGoogleTranslateParams(source: language,
                                             target: self.friendLanguage,
                                             text:   text)
        let translator = ROGoogleTranslate()
        translator.apiKey = "AIzaSyBePVek0atgmg3pzKQyN4oo6a7Oggog3sQ"
        translator.translate(params: params) { (value) in
            let message = ["sender_id": senderId, "name": senderDisplayName, "text": value, "ownText": text,
                           "transText": value]
                
            ref.setValue(message)
        }
        self.finishSendingMessage()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }

}


