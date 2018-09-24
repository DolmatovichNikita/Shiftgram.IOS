import Foundation

extension String {
    
    func parseCNPhone() -> String {
        let phone = self.filter { (ch) -> Bool in
            (ch >= "0" && ch <= "9") || ch == "+"
        }
        
        return phone
    }
}
