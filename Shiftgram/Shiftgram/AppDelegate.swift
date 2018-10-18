import UIKit
import CoreData
import AWSCognito
import Firebase

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
    
    public func navigateToVideo(conversationName: String, friendLanguage: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let videoViewController = storyboard.instantiateViewController(withIdentifier: "VideoViewController") as? VideoViewController
        videoViewController?.conversationName = conversationName
        videoViewController?.friendLaguage = friendLanguage
        self.window?.rootViewController = videoViewController
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

}

