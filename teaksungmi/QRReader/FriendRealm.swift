
import Foundation
import RealmSwift

class Friend: Object {
    @objc dynamic var uuid: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var age: String = ""
    @objc dynamic var grade: String = ""
    @objc dynamic var classN: String = ""
    @objc dynamic var phoneN: String = ""
    @objc dynamic var sung: String = ""
    @objc dynamic var PphonN: String = ""

    
    override static func primaryKey() -> String? {
        return "uuid"
    }
}


