import UIKit
import CoreData
import AWSCognito
import Firebase
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.initControls()
        self.registerCognito()
        FirebaseApp.configure()
        
        let storyborad = UIStoryboard(name: "Main", bundle: nil)
        if self.isAuth() {
            let initialViewController = storyborad.instantiateViewController(withIdentifier: "Menu")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } else {
            let initialViewController = storyborad.instantiateViewController(withIdentifier: "Initial")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
 
        return true
    }
    
    public func navigateToVideo() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "Menu")
        self.window?.rootViewController = menuViewController
        self.window?.makeKeyAndVisible()
    }
    
    private func registerCognito() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUCentral1,
                                                                identityPoolId:"eu-central-1:2e181e24-28d0-4839-84a3-011b2fe795f5")
        
        let configuration = AWSServiceConfiguration(region:.EUCentral1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }

    private func isAuth() -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var isAuth = false
        
        do {
            let count = try self.persistentContainer.viewContext.fetch(request).count
            if count > 0 {
                let user = try self.persistentContainer.viewContext.fetch(request).first as! User
                print(user.isAuth)
                isAuth = user.isAuth
            }
        } catch {
            print("Failed")
        }
        
        return isAuth
    }
    
    private func initControls() {
        UINavigationBar.appearance().backgroundColor = UIColor.white
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.initAudioSession()
        self.initConversations()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Shiftgram")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func initAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    private func initConversations() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversation")
        var conversations = [Conversation]()
        
        do {
            conversations = try self.persistentContainer.viewContext.fetch(request) as! [Conversation]
        } catch {
            print("Failed")
        }
        let request1 = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var userId: Int32 = 0
        
        do {
            let users = try self.persistentContainer.viewContext.fetch(request1)
            if users.count > 0 {
                let user = users.first as! User
                userId = user.id
            }
            
        } catch {
            print("Failed")
        }
        for conversation in conversations {
            let conversationName = String(userId * conversation.accountBId)
            let query = Constants.refs.databaseRoot.child(conversationName + "notification").queryLimited(toLast: 10)
            
            _ = query.observe(.childAdded, with: { snapshot in
                if let data = snapshot.value as? [String: String] {
                    let id = data["sender_id"]
                    let name = data["name"]
                    let video = data["videoCall"]
                    
                    if id != String(userId) {
                        if video != nil && !(video?.isEmpty)! {
                            self.incomingCall(senderName: name!)
                        }
                    }
                }
            })
        }
    }
    
    private func incomingCall(senderName: String) {
        let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "Shiftgram"))
        provider.setDelegate(self, queue: nil)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: senderName)
        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
    }
}

extension AppDelegate: CXProviderDelegate {
    
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }
}
