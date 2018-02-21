import Foundation
import SourceKittenFramework

extension String {
    
    var ns: NSString {
        return self as NSString
    }
    
    func dropLast(while predicate: (Character) -> Bool) -> String {
        
        var droped = self
        var lastCharacter = last
        
        while true {
            guard let _last = lastCharacter, predicate(_last) else {
                break
            }
            droped = String(droped.dropLast())
            lastCharacter = droped.last
        }

        return droped
    }
    
    func repeated(_ count: Int) -> String {
        return String(repeating: self, count: count)
    }
}
