
import Foundation
import UIKit
import RealmSwift
class StudentInfo: UIViewController{
    
    
    
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var grade: UILabel!
    @IBOutlet weak var classN: UILabel!
    @IBOutlet weak var sung: UILabel!
    @IBOutlet weak var phoneN: UILabel!
    @IBOutlet weak var PphoneN: UILabel!
    var i = 0


    override func viewDidLoad() {
        
        let realm = try! Realm()
        let friends = realm.objects(Friend.self)
        print(i)
        age.text = friends[i].age
        grade.text = friends[i].grade
        classN.text = friends[i].classN
        sung.text = friends[i].sung
        phoneN.text = friends[i].phoneN
        PphoneN.text = friends[i].PphonN
    }
       
}
