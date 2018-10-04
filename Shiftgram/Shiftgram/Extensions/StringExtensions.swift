import Foundation

extension String {
    
    func parseCNPhone() -> String {
        let phone = self.filter { (ch) -> Bool in
            (ch >= "0" && ch <= "9") || ch == "+"
        }
        
        return phone
    }
    
    func parseLanguage() -> String {
        var language = ""
        
        for ch in self {
            if ch != "-" {
                language.append(ch)
            } else {
                break
            }
        }
        
        return language
    }
}
