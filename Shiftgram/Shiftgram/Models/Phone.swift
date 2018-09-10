import Foundation

struct Phone {
    let id: Int
    let country: String
    let code: String
    
    init(item: NSDictionary) {
        self.id = item["Id"] as! Int
        self.country = item["Country"] as! String
        self.code = item["Code"] as! String
    }
}
