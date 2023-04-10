

import Foundation
import RealmSwift

class Me: Object {
    @objc dynamic var uuid: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var admin: String = ""
    @objc dynamic var age: String = ""
    @objc dynamic var grade: String = ""
    @objc dynamic var classN: String = ""
    @objc dynamic var phoneN: String = ""
    @objc dynamic var sung: String = ""
    @objc dynamic var PphonN: String = ""
    @objc dynamic var MTutoN: String = ""
    @objc dynamic var FTutoN: String = ""
    @objc dynamic var AdTutoN: String = ""
    
    

    
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
}


// 서버 추가하면서 쓰지 않게된 내부 데이터베이스
//class tuchLL: Object {
//    @objc dynamic var P_key: String = ""
//
//    @objc dynamic var tuchLat: String = ""
//    @objc dynamic var tuchLong: String = ""
//
//
//    override static func primaryKey() -> String? {
//        return "P_key"
//    }
//}

